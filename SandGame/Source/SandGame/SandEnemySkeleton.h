#pragma once

#include "CoreMinimal.h"
#include "SandEnemyBase.h"
#include "SandEnemySkeleton.generated.h"

UCLASS()
class SANDGAME_API ASandEnemySkeleton : public ASandEnemyBase
{
	GENERATED_BODY()

public:
	ASandEnemySkeleton();

protected:
	virtual void BeginPlay() override;
	virtual void PerformAttack() override;

	// Skeleton blocks 30% of incoming damage
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Combat")
	float BlockChance = 0.3f;
};
