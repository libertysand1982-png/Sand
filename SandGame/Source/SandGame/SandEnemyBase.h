#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "SandEnemyBase.generated.h"

class USandHealthComponent;
class UAIPerceptionComponent;
class UAISenseConfig_Sight;
class UBehaviorTree;
class UWidgetComponent;

UENUM(BlueprintType)
enum class EEnemyState : uint8
{
	Idle,
	Patrolling,
	Chasing,
	Attacking,
	Dead
};

UCLASS(Abstract)
class SANDGAME_API ASandEnemyBase : public ACharacter
{
	GENERATED_BODY()

public:
	ASandEnemyBase();

	virtual void Tick(float DeltaTime) override;

	UFUNCTION(BlueprintCallable, Category="AI")
	void SetEnemyState(EEnemyState NewState);

	UFUNCTION(BlueprintPure, Category="AI")
	EEnemyState GetEnemyState() const { return CurrentState; }

	USandHealthComponent* GetHealthComponent() const { return HealthComponent; }

	UFUNCTION(BlueprintCallable, Category="Combat")
	virtual void PerformAttack();

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="AI")
	UBehaviorTree* BehaviorTree;

	UPROPERTY(BlueprintReadOnly, Category="AI")
	EEnemyState CurrentState = EEnemyState::Idle;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Combat")
	float AttackDamage = 15.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Combat")
	float AttackRange = 120.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Combat")
	float AttackCooldown = 1.5f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Rewards")
	int32 CoinReward = 5;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Rewards")
	float XPReward = 50.f;

protected:
	virtual void BeginPlay() override;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Health")
	USandHealthComponent* HealthComponent;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="UI")
	UWidgetComponent* HealthBarWidget;

	UFUNCTION()
	virtual void OnDeath();

	UFUNCTION()
	void OnHealthChanged(float NewHealth, float MaxHealth);

	bool bCanAttack = true;
	FTimerHandle AttackCooldownTimer;
	FTimerHandle DeathCleanupTimer;

private:
	void ResetAttackCooldown();
	void CleanupAfterDeath();
};
