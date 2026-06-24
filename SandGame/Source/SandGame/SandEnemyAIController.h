#pragma once

#include "CoreMinimal.h"
#include "AIController.h"
#include "Perception/AIPerceptionComponent.h"
#include "SandEnemyAIController.generated.h"

class UAISenseConfig_Sight;
class UAISenseConfig_Hearing;
class ASandCharacter;

UCLASS()
class SANDGAME_API ASandEnemyAIController : public AAIController
{
	GENERATED_BODY()

public:
	ASandEnemyAIController();

	virtual void OnPossess(APawn* InPawn) override;
	virtual void Tick(float DeltaTime) override;

	UFUNCTION(BlueprintCallable, Category="AI")
	ASandCharacter* GetPerceivedPlayer() const { return PerceivedPlayer; }

	static const FName BB_TargetPlayer;
	static const FName BB_PatrolLocation;
	static const FName BB_EnemyState;
	static const FName BB_bCanSeePlayer;
	static const FName BB_AttackRange;

protected:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="AI")
	UAIPerceptionComponent* PerceptionComponent;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="AI")
	UAISenseConfig_Sight* SightConfig;

private:
	UFUNCTION()
	void OnPerceptionUpdated(const TArray<AActor*>& UpdatedActors);

	void UpdateBlackboard();

	ASandCharacter* PerceivedPlayer = nullptr;
};
