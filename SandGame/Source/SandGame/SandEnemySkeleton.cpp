#include "SandEnemySkeleton.h"
#include "GameFramework/CharacterMovementComponent.h"

ASandEnemySkeleton::ASandEnemySkeleton()
{
	// Skeleton: medium speed, medium damage, blocks attacks
	AttackDamage = 15.f;
	AttackRange = 140.f;
	AttackCooldown = 1.2f;
	CoinReward = 5;

	GetCharacterMovement()->MaxWalkSpeed = 280.f;
}

void ASandEnemySkeleton::BeginPlay()
{
	Super::BeginPlay();
}

void ASandEnemySkeleton::PerformAttack()
{
	Super::PerformAttack();
}
