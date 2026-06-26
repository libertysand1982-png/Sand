#pragma once

#include "CoreMinimal.h"
#include "SandEnemyBase.h"
#include "SandEnemyVampire.generated.h"

UCLASS()
class SANDGAME_API ASandEnemyVampire : public ASandEnemyBase
{
	GENERATED_BODY()

public:
	ASandEnemyVampire();

protected:
	virtual void BeginPlay() override;
	virtual void PerformAttack() override;
	virtual void OnDeath();

	// Vampire regenerates health when low
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Vampire")
	float LifeStealPercent = 0.3f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Vampire")
	float RegenThresholdPercent = 0.4f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Vampire")
	float RegenAmount = 5.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Vampire")
	float RegenInterval = 1.f;

private:
	FTimerHandle RegenTimer;
	void TickRegen();
};
