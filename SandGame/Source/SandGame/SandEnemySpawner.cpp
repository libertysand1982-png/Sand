#include "SandEnemySpawner.h"
#include "SandEnemyBase.h"
#include "SandGameMode.h"
#include "NavigationSystem.h"
#include "Kismet/GameplayStatics.h"

ASandEnemySpawner::ASandEnemySpawner()
{
	PrimaryActorTick.bCanEverTick = false;
}

void ASandEnemySpawner::BeginPlay()
{
	Super::BeginPlay();

	if (bAutoStart)
	{
		GetWorld()->GetTimerManager().SetTimer(WaveTimer, this,
			&ASandEnemySpawner::SpawnWave, 3.f, false);
	}
}

void ASandEnemySpawner::StartWaves()
{
	CurrentWave = 0;
	SpawnWave();
}

void ASandEnemySpawner::SpawnWave()
{
	if (CurrentWave >= MaxWaves)
	{
		if (ASandGameMode* GM = Cast<ASandGameMode>(UGameplayStatics::GetGameMode(GetWorld())))
			GM->TriggerWin();
		return;
	}

	CurrentWave++;

	// Collect available enemy classes with weights
	TArray<TSubclassOf<ASandEnemyBase>> WeightedPool;
	for (const FEnemySpawnEntry& Entry : EnemyPool)
	{
		if (!Entry.EnemyClass)
			continue;
		int32 Copies = FMath::RoundToInt(Entry.SpawnWeight * 10.f);
		for (int32 i = 0; i < Copies; i++)
			WeightedPool.Add(Entry.EnemyClass);
	}

	if (WeightedPool.IsEmpty())
		return;

	UNavigationSystemV1* NavSys = UNavigationSystemV1::GetCurrent(GetWorld());
	const int32 ToSpawn = EnemiesPerWave + (CurrentWave - 1) * 2;

	for (int32 i = 0; i < ToSpawn; i++)
	{
		FNavLocation NavLoc;
		bool bFound = false;

		if (NavSys)
		{
			bFound = NavSys->GetRandomReachablePointInRadius(
				GetActorLocation(), SpawnRadius, NavLoc);
		}

		FVector SpawnLoc = bFound
			? NavLoc.Location
			: GetActorLocation() + FMath::VRand() * SpawnRadius;

		SpawnLoc.Z += 100.f;

		const int32 Idx = FMath::RandRange(0, WeightedPool.Num() - 1);
		TSubclassOf<ASandEnemyBase> EnemyClass = WeightedPool[Idx];

		FActorSpawnParameters Params;
		Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AdjustIfPossibleButAlwaysSpawn;

		if (ASandEnemyBase* Enemy = GetWorld()->SpawnActor<ASandEnemyBase>(
			EnemyClass, SpawnLoc, FRotator::ZeroRotator, Params))
		{
			SpawnedEnemies.Add(Enemy);
		}
	}

	// Schedule next wave
	GetWorld()->GetTimerManager().SetTimer(WaveTimer, this,
		&ASandEnemySpawner::NextWave, TimeBetweenWaves, false);
}

void ASandEnemySpawner::NextWave()
{
	// Check all enemies dead before spawning next wave
	bool bAllDead = true;
	for (TWeakObjectPtr<ASandEnemyBase> EnemyPtr : SpawnedEnemies)
	{
		if (EnemyPtr.IsValid() && EnemyPtr->GetHealthComponent()->IsAlive())
		{
			bAllDead = false;
			break;
		}
	}

	SpawnedEnemies.Empty();

	if (bAllDead)
		SpawnWave();
	else
	{
		// Wait and check again
		GetWorld()->GetTimerManager().SetTimer(WaveTimer, this,
			&ASandEnemySpawner::NextWave, 5.f, false);
	}
}
