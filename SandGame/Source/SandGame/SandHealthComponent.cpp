#include "SandHealthComponent.h"

USandHealthComponent::USandHealthComponent()
{
	PrimaryComponentTick.bCanEverTick = false;
}

void USandHealthComponent::BeginPlay()
{
	Super::BeginPlay();
	CurrentHealth = MaxHealth;
}

void USandHealthComponent::ApplyDamage(float DamageAmount, AActor* DamageCauser)
{
	if (!bIsAlive || bInvincible || DamageAmount <= 0.f)
		return;

	CurrentHealth = FMath::Clamp(CurrentHealth - DamageAmount, 0.f, MaxHealth);
	OnHealthChanged.Broadcast(CurrentHealth, MaxHealth);

	if (CurrentHealth <= 0.f)
	{
		bIsAlive = false;
		OnDeath.Broadcast();
	}
}

void USandHealthComponent::Heal(float HealAmount)
{
	if (!bIsAlive || HealAmount <= 0.f)
		return;

	CurrentHealth = FMath::Clamp(CurrentHealth + HealAmount, 0.f, MaxHealth);
	OnHealthChanged.Broadcast(CurrentHealth, MaxHealth);
}

float USandHealthComponent::GetHealthPercent() const
{
	if (MaxHealth <= 0.f)
		return 0.f;
	return CurrentHealth / MaxHealth;
}
