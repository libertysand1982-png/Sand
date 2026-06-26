#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "SandEnemySpawner.generated.h"

class ASandEnemyBase;

USTRUCT(BlueprintType)
struct FEnemySpawnEntry
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TSubclassOf<ASandEnemyBase> EnemyClass;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int32 Count = 1;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	float SpawnWeight = 1.f;
};

UCLASS()
class SANDGAME_API ASandEnemySpawner : public AActor
{
	GENERATED_BODY()

public:
	ASandEnemySpawner();

	UFUNCTION(BlueprintCallable, Category="Spawn")
	void SpawnWave();

	UFUNCTION(BlueprintCallable, Category="Spawn")
	void StartWaves();

	UFUNCTION(BlueprintPure, Category="Spawn")
	int32 GetCurrentWave() const { return CurrentWave; }

protected:
	virtual void BeginPlay() override;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Spawn")
	TArray<FEnemySpawnEntry> EnemyPool;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Spawn")
	float SpawnRadius = 800.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Spawn")
	int32 EnemiesPerWave = 5;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Spawn")
	float TimeBetweenWaves = 30.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Spawn")
	bool bAutoStart = true;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Spawn")
	int32 MaxWaves = 5;

	UPROPERTY(BlueprintReadOnly, Category="Spawn")
	int32 CurrentWave = 0;

private:
	void NextWave();
	FTimerHandle WaveTimer;
	TArray<TWeakObjectPtr<ASandEnemyBase>> SpawnedEnemies;
};
