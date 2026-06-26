#include "SandCharacter.h"
#include "SandHealthComponent.h"
#include "SandEnemyBase.h"
#include "SandInteractable.h"

#include "Camera/CameraComponent.h"
#include "Components/CapsuleComponent.h"
#include "Components/SphereComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"
#include "Kismet/GameplayStatics.h"
#include "DrawDebugHelpers.h"

ASandCharacter::ASandCharacter()
{
	PrimaryActorTick.bCanEverTick = true;

	GetCapsuleComponent()->InitCapsuleSize(42.f, 96.f);

	bUseControllerRotationPitch = false;
	bUseControllerRotationYaw = false;
	bUseControllerRotationRoll = false;

	GetCharacterMovement()->bOrientRotationToMovement = true;
	GetCharacterMovement()->RotationRate = FRotator(0.f, 500.f, 0.f);
	GetCharacterMovement()->MaxWalkSpeed = WalkSpeed;
	GetCharacterMovement()->MinAnalogWalkSpeed = 20.f;
	GetCharacterMovement()->BrakingDecelerationWalking = 2000.f;
	GetCharacterMovement()->JumpZVelocity = 600.f;

	SpringArm = CreateDefaultSubobject<USpringArmComponent>(TEXT("SpringArm"));
	SpringArm->SetupAttachment(RootComponent);
	SpringArm->TargetArmLength = 400.f;
	SpringArm->bUsePawnControlRotation = true;
	SpringArm->bEnableCameraLag = true;
	SpringArm->CameraLagSpeed = 8.f;
	SpringArm->SetRelativeLocation(FVector(0.f, 0.f, 60.f));

	FollowCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FollowCamera"));
	FollowCamera->SetupAttachment(SpringArm, USpringArmComponent::SocketName);
	FollowCamera->bUsePawnControlRotation = false;

	HealthComponent = CreateDefaultSubobject<USandHealthComponent>(TEXT("HealthComponent"));

	MeleeHitbox = CreateDefaultSubobject<USphereComponent>(TEXT("MeleeHitbox"));
	MeleeHitbox->SetupAttachment(RootComponent);
	MeleeHitbox->SetRelativeLocation(FVector(80.f, 0.f, 0.f));
	MeleeHitbox->SetSphereRadius(60.f);
	MeleeHitbox->SetCollisionEnabled(ECollisionEnabled::NoCollision);
}

void ASandCharacter::BeginPlay()
{
	Super::BeginPlay();

	if (APlayerController* PC = Cast<APlayerController>(Controller))
	{
		if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
			ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer()))
		{
			Subsystem->AddMappingContext(DefaultMappingContext, 0);
		}
	}

	HealthComponent->OnDeath.AddDynamic(this, &ASandCharacter::OnDeath);
}

void ASandCharacter::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);
}

void ASandCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	if (UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent))
	{
		EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &ASandCharacter::Move);
		EIC->BindAction(LookAction, ETriggerEvent::Triggered, this, &ASandCharacter::Look);
		EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
		EIC->BindAction(JumpAction, ETriggerEvent::Completed, this, &ACharacter::StopJumping);
		EIC->BindAction(AttackAction, ETriggerEvent::Started, this, &ASandCharacter::OnAttackInput);
		EIC->BindAction(InteractAction, ETriggerEvent::Started, this, &ASandCharacter::OnInteractInput);
		EIC->BindAction(SprintAction, ETriggerEvent::Started, this, &ASandCharacter::StartSprint);
		EIC->BindAction(SprintAction, ETriggerEvent::Completed, this, &ASandCharacter::StopSprint);
	}
}

void ASandCharacter::Move(const FInputActionValue& Value)
{
	const FVector2D MoveDir = Value.Get<FVector2D>();
	if (!Controller || MoveDir.IsZero())
		return;

	const FRotator Rot = Controller->GetControlRotation();
	const FRotator YawRot(0, Rot.Yaw, 0);
	const FVector ForwardDir = FRotationMatrix(YawRot).GetUnitAxis(EAxis::X);
	const FVector RightDir = FRotationMatrix(YawRot).GetUnitAxis(EAxis::Y);

	AddMovementInput(ForwardDir, MoveDir.Y);
	AddMovementInput(RightDir, MoveDir.X);
}

void ASandCharacter::Look(const FInputActionValue& Value)
{
	const FVector2D LookDir = Value.Get<FVector2D>();
	if (!Controller)
		return;
	AddControllerYawInput(LookDir.X);
	AddControllerPitchInput(LookDir.Y);
}

void ASandCharacter::StartSprint()
{
	bIsSprinting = true;
	GetCharacterMovement()->MaxWalkSpeed = SprintSpeed;
}

void ASandCharacter::StopSprint()
{
	bIsSprinting = false;
	GetCharacterMovement()->MaxWalkSpeed = WalkSpeed;
}

void ASandCharacter::OnAttackInput()
{
	Attack();
}

void ASandCharacter::Attack()
{
	if (bIsAttacking || !HealthComponent->IsAlive())
		return;

	bIsAttacking = true;

	// Activate melee hitbox briefly then apply damage
	GetWorld()->GetTimerManager().SetTimer(MeleeHitTimer, this,
		&ASandCharacter::PerformMeleeAttack, 0.2f, false);

	GetWorld()->GetTimerManager().SetTimer(AttackCooldownTimer, this,
		&ASandCharacter::ResetAttack, AttackCooldown, false);
}

void ASandCharacter::PerformMeleeAttack()
{
	// Sphere trace in front of character to detect enemies
	const FVector Start = GetActorLocation();
	const FVector Forward = GetActorForwardVector();
	const FVector End = Start + Forward * AttackRange;

	TArray<FHitResult> Hits;
	FCollisionQueryParams Params;
	Params.AddIgnoredActor(this);

	GetWorld()->SweepMultiByChannel(Hits, Start, End,
		FQuat::Identity, ECC_Pawn,
		FCollisionShape::MakeSphere(80.f), Params);

	for (const FHitResult& Hit : Hits)
	{
		if (ASandEnemyBase* Enemy = Cast<ASandEnemyBase>(Hit.GetActor()))
		{
			Enemy->GetHealthComponent()->ApplyDamage(AttackDamage, this);
			break; // One hit per swing
		}
	}

#if WITH_EDITOR
	DrawDebugSphere(GetWorld(), End, 80.f, 8, FColor::Red, false, 0.5f);
#endif
}

void ASandCharacter::ResetAttack()
{
	bIsAttacking = false;
}

void ASandCharacter::OnInteractInput()
{
	Interact();
}

void ASandCharacter::Interact()
{
	// Line trace for interactable objects
	const FVector Start = FollowCamera->GetComponentLocation();
	const FVector End = Start + FollowCamera->GetForwardVector() * InteractRange;

	FHitResult Hit;
	FCollisionQueryParams Params;
	Params.AddIgnoredActor(this);

	if (GetWorld()->LineTraceSingleByChannel(Hit, Start, End, ECC_Visibility, Params))
	{
		if (ISandInteractable* Interactable = Cast<ISandInteractable>(Hit.GetActor()))
		{
			Interactable->Interact(this);
		}
	}
}

void ASandCharacter::AddCoins(int32 Amount)
{
	Coins += Amount;
}

void ASandCharacter::OnDeath()
{
	GetCharacterMovement()->DisableMovement();
	GetCapsuleComponent()->SetCollisionEnabled(ECollisionEnabled::NoCollision);

	// Notify GameMode
	if (APlayerController* PC = Cast<APlayerController>(Controller))
	{
		PC->SetInputMode(FInputModeUIOnly());
	}
}
