#include "SandEnemyBase.h"
#include "SandHealthComponent.h"
#include "SandCharacter.h"

#include "Components/WidgetComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Kismet/GameplayStatics.h"
#include "AIController.h"
#include "BrainComponent.h"

ASandEnemyBase::ASandEnemyBase()
{
	PrimaryActorTick.bCanEverTick = true;

	HealthComponent = CreateDefaultSubobject<USandHealthComponent>(TEXT("HealthComponent"));

	HealthBarWidget = CreateDefaultSubobject<UWidgetComponent>(TEXT("HealthBarWidget"));
	HealthBarWidget->SetupAttachment(RootComponent);
	HealthBarWidget->SetRelativeLocation(FVector(0.f, 0.f, 120.f));
	HealthBarWidget->SetWidgetSpace(EWidgetSpace::Screen);
	HealthBarWidget->SetDrawSize(FVector2D(100.f, 12.f));

	AutoPossessAI = EAutoPossessAI::PlacedInWorldOrSpawned;
}

void ASandEnemyBase::BeginPlay()
{
	Super::BeginPlay();

	HealthComponent->OnDeath.AddDynamic(this, &ASandEnemyBase::OnDeath);
	HealthComponent->OnHealthChanged.AddDynamic(this, &ASandEnemyBase::OnHealthChanged);

	// Start the behavior tree via AIController
	if (AAIController* AIC = Cast<AAIController>(GetController()))
	{
		if (BehaviorTree)
			AIC->RunBehaviorTree(BehaviorTree);
	}
}

void ASandEnemyBase::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);
}

void ASandEnemyBase::SetEnemyState(EEnemyState NewState)
{
	if (CurrentState == EEnemyState::Dead)
		return;
	CurrentState = NewState;
}

void ASandEnemyBase::PerformAttack()
{
	if (!bCanAttack || CurrentState == EEnemyState::Dead)
		return;

	// Sphere overlap to hit the player
	TArray<FOverlapResult> Overlaps;
	FCollisionQueryParams Params;
	Params.AddIgnoredActor(this);

	GetWorld()->OverlapMultiByChannel(Overlaps,
		GetActorLocation(), FQuat::Identity,
		ECC_Pawn, FCollisionShape::MakeSphere(AttackRange), Params);

	for (const FOverlapResult& Overlap : Overlaps)
	{
		if (ASandCharacter* Player = Cast<ASandCharacter>(Overlap.GetActor()))
		{
			Player->GetHealthComponent()->ApplyDamage(AttackDamage, this);
			break;
		}
	}

	bCanAttack = false;
	GetWorld()->GetTimerManager().SetTimer(AttackCooldownTimer, this,
		&ASandEnemyBase::ResetAttackCooldown, AttackCooldown, false);
}

void ASandEnemyBase::ResetAttackCooldown()
{
	bCanAttack = true;
}

void ASandEnemyBase::OnHealthChanged(float NewHealth, float MaxHealth)
{
	// Blueprint can handle UI update via the OnHealthChanged delegate
}

void ASandEnemyBase::OnDeath()
{
	CurrentState = EEnemyState::Dead;

	// Stop AI
	if (AAIController* AIC = Cast<AAIController>(GetController()))
	{
		if (AIC->GetBrainComponent())
			AIC->GetBrainComponent()->StopLogic("Dead");
		AIC->UnPossess();
	}

	GetCharacterMovement()->DisableMovement();
	GetCapsuleComponent()->SetCollisionEnabled(ECollisionEnabled::NoCollision);
	HealthBarWidget->SetVisibility(false);

	// Reward the player
	if (ASandCharacter* Player = Cast<ASandCharacter>(
		UGameplayStatics::GetPlayerCharacter(GetWorld(), 0)))
	{
		Player->AddCoins(CoinReward);
	}

	// Dissolve / cleanup after 5 seconds
	GetWorld()->GetTimerManager().SetTimer(DeathCleanupTimer, this,
		&ASandEnemyBase::CleanupAfterDeath, 5.f, false);
}

void ASandEnemyBase::CleanupAfterDeath()
{
	Destroy();
}
