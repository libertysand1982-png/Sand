#include "SandEnemyZombie.h"
#include "GameFramework/CharacterMovementComponent.h"

ASandEnemyZombie::ASandEnemyZombie()
{
	// Zombie: slow, hits hard
	AttackDamage = 20.f;
	AttackRange = 130.f;
	AttackCooldown = 2.0f;
	CoinReward = 3;

	GetCharacterMovement()->MaxWalkSpeed = 180.f;
}

void ASandEnemyZombie::BeginPlay()
{
	Super::BeginPlay();
}

void ASandEnemyZombie::PerformAttack()
{
	Super::PerformAttack();
}
