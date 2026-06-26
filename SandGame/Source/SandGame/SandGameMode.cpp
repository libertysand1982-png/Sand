#include "SandGameMode.h"
#include "SandCharacter.h"
#include "SandEnemyBase.h"
#include "SandPlayerController.h"
#include "Kismet/GameplayStatics.h"

ASandGameMode::ASandGameMode()
{
	DefaultPawnClass = ASandCharacter::StaticClass();
	PlayerControllerClass = ASandPlayerController::StaticClass();
}

void ASandGameMode::BeginPlay()
{
	Super::BeginPlay();
	GameStartTime = GetWorld()->GetTimeSeconds();
}

void ASandGameMode::PlayerDied()
{
	OnGameOver.Broadcast();

	GetWorld()->GetTimerManager().SetTimer(RespawnTimer, this,
		&ASandGameMode::RespawnPlayer, RespawnDelay, false);
}

void ASandGameMode::RespawnPlayer()
{
	if (APlayerController* PC = UGameplayStatics::GetPlayerController(GetWorld(), 0))
	{
		RestartPlayer(PC);
	}
}

void ASandGameMode::EnemyKilled(ASandEnemyBase* Enemy)
{
	EnemiesKilled++;
}

void ASandGameMode::TriggerWin()
{
	OnGameWon.Broadcast();
}

float ASandGameMode::GetElapsedTime() const
{
	return GetWorld()->GetTimeSeconds() - GameStartTime;
}
