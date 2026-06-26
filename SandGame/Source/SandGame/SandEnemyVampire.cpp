#include "SandEnemyVampire.h"
#include "SandHealthComponent.h"
#include "SandCharacter.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Kismet/GameplayStatics.h"

ASandEnemyVampire::ASandEnemyVampire()
{
	// Vampire: fast, life steal, regenerates at low HP
	AttackDamage = 25.f;
	AttackRange = 150.f;
	AttackCooldown = 1.0f;
	CoinReward = 15;

	GetCharacterMovement()->MaxWalkSpeed = 380.f;
}

void ASandEnemyVampire::BeginPlay()
{
	Super::BeginPlay();

	// Start low HP regen ticker
	GetWorld()->GetTimerManager().SetTimer(RegenTimer, this,
		&ASandEnemyVampire::TickRegen, RegenInterval, true);
}

void ASandEnemyVampire::TickRegen()
{
	if (!HealthComponent->IsAlive())
		return;

	if (HealthComponent->GetHealthPercent() < RegenThresholdPercent)
	{
		HealthComponent->Heal(RegenAmount);
	}
}

void ASandEnemyVampire::PerformAttack()
{
	float HealthBefore = HealthComponent->GetHealth();
	Super::PerformAttack();

	// Life steal: heal for a percentage of damage dealt
	float DamageDealt = AttackDamage;
	HealthComponent->Heal(DamageDealt * LifeStealPercent);
}

void ASandEnemyVampire::OnDeath()
{
	GetWorld()->GetTimerManager().ClearTimer(RegenTimer);
	Super::OnDeath();
}
