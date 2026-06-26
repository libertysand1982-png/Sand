#include "SandEnemyAIController.h"
#include "SandEnemyBase.h"
#include "SandCharacter.h"
#include "SandHealthComponent.h"

#include "Perception/AIPerceptionComponent.h"
#include "Perception/AISenseConfig_Sight.h"
#include "Perception/AISenseConfig_Hearing.h"
#include "BehaviorTree/BlackboardComponent.h"
#include "BehaviorTree/BehaviorTreeComponent.h"
#include "BehaviorTree/BehaviorTree.h"
#include "Navigation/PathFollowingComponent.h"
#include "Kismet/GameplayStatics.h"

const FName ASandEnemyAIController::BB_TargetPlayer   = TEXT("TargetPlayer");
const FName ASandEnemyAIController::BB_PatrolLocation = TEXT("PatrolLocation");
const FName ASandEnemyAIController::BB_EnemyState     = TEXT("EnemyState");
const FName ASandEnemyAIController::BB_bCanSeePlayer  = TEXT("bCanSeePlayer");
const FName ASandEnemyAIController::BB_AttackRange    = TEXT("AttackRange");

ASandEnemyAIController::ASandEnemyAIController()
{
	SightConfig = CreateDefaultSubobject<UAISenseConfig_Sight>(TEXT("SightConfig"));
	SightConfig->SightRadius              = 1500.f;
	SightConfig->LoseSightRadius          = 1800.f;
	SightConfig->PeripheralVisionAngleDegrees = 60.f;
	SightConfig->SetMaxAge(5.f);
	SightConfig->DetectionByAffiliation.bDetectEnemies = true;
	SightConfig->DetectionByAffiliation.bDetectNeutrals = true;
	SightConfig->DetectionByAffiliation.bDetectFriendlies = true;

	PerceptionComponent = CreateDefaultSubobject<UAIPerceptionComponent>(TEXT("PerceptionComponent"));
	PerceptionComponent->ConfigureSense(*SightConfig);
	PerceptionComponent->SetDominantSense(SightConfig->GetSenseImplementation());

	SetPerceptionComponent(*PerceptionComponent);

	bWantsPlayerState = false;
}

void ASandEnemyAIController::OnPossess(APawn* InPawn)
{
	Super::OnPossess(InPawn);

	PerceptionComponent->OnTargetPerceptionUpdated.AddDynamic(
		this, &ASandEnemyAIController::OnPerceptionUpdated);

	if (ASandEnemyBase* Enemy = Cast<ASandEnemyBase>(InPawn))
	{
		if (Enemy->BehaviorTree)
		{
			RunBehaviorTree(Enemy->BehaviorTree);
			if (Blackboard)
				Blackboard->SetValueAsFloat(BB_AttackRange, Enemy->AttackRange);
		}
	}
}

void ASandEnemyAIController::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);
	UpdateBlackboard();
}

void ASandEnemyAIController::OnPerceptionUpdated(const TArray<AActor*>& UpdatedActors)
{
	for (AActor* Actor : UpdatedActors)
	{
		if (ASandCharacter* Player = Cast<ASandCharacter>(Actor))
		{
			FActorPerceptionBlueprintInfo Info;
			PerceptionComponent->GetActorsPerception(Player, Info);

			bool bCurrentlySensed = false;
			for (const FAIStimulus& Stimulus : Info.LastSensedStimuli)
			{
				if (Stimulus.WasSuccessfullySensed())
				{
					bCurrentlySensed = true;
					break;
				}
			}

			PerceivedPlayer = bCurrentlySensed ? Player : nullptr;
			break;
		}
	}
}

void ASandEnemyAIController::UpdateBlackboard()
{
	if (!Blackboard)
		return;

	const bool bSeePlayer = (PerceivedPlayer != nullptr &&
		PerceivedPlayer->GetHealthComponent()->IsAlive());

	Blackboard->SetValueAsBool(BB_bCanSeePlayer, bSeePlayer);

	if (bSeePlayer)
		Blackboard->SetValueAsObject(BB_TargetPlayer, PerceivedPlayer);
	else
		Blackboard->ClearValue(BB_TargetPlayer);
}
