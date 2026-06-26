#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "SandGameMode.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnGameOver);
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnGameWon);

UCLASS()
class SANDGAME_API ASandGameMode : public AGameModeBase
{
	GENERATED_BODY()

public:
	ASandGameMode();

	UPROPERTY(BlueprintAssignable, Category="Game")
	FOnGameOver OnGameOver;

	UPROPERTY(BlueprintAssignable, Category="Game")
	FOnGameWon OnGameWon;

	UFUNCTION(BlueprintCallable, Category="Game")
	void PlayerDied();

	UFUNCTION(BlueprintCallable, Category="Game")
	void EnemyKilled(class ASandEnemyBase* Enemy);

	UFUNCTION(BlueprintCallable, Category="Game")
	void TriggerWin();

	UFUNCTION(BlueprintPure, Category="Game")
	int32 GetTotalEnemiesKilled() const { return EnemiesKilled; }

	UFUNCTION(BlueprintPure, Category="Game")
	float GetElapsedTime() const;

protected:
	virtual void BeginPlay() override;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Game")
	float RespawnDelay = 5.f;

	UPROPERTY(BlueprintReadOnly, Category="Game")
	int32 EnemiesKilled = 0;

private:
	void RespawnPlayer();
	FTimerHandle RespawnTimer;
	float GameStartTime = 0.f;
};
