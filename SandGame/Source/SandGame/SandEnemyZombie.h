#pragma once

#include "CoreMinimal.h"
#include "SandEnemyBase.h"
#include "SandEnemyZombie.generated.h"

UCLASS()
class SANDGAME_API ASandEnemyZombie : public ASandEnemyBase
{
	GENERATED_BODY()

public:
	ASandEnemyZombie();

protected:
	virtual void BeginPlay() override;
	virtual void PerformAttack() override;
};
