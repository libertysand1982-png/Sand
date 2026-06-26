#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "SandHealthComponent.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnHealthChanged, float, NewHealth, float, MaxHealth);
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnDeath);

UCLASS(ClassGroup=(SandGame), meta=(BlueprintSpawnableComponent))
class SANDGAME_API USandHealthComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	USandHealthComponent();

	UPROPERTY(BlueprintAssignable, Category="Health")
	FOnHealthChanged OnHealthChanged;

	UPROPERTY(BlueprintAssignable, Category="Health")
	FOnDeath OnDeath;

	UFUNCTION(BlueprintCallable, Category="Health")
	void ApplyDamage(float DamageAmount, AActor* DamageCauser);

	UFUNCTION(BlueprintCallable, Category="Health")
	void Heal(float HealAmount);

	UFUNCTION(BlueprintPure, Category="Health")
	float GetHealth() const { return CurrentHealth; }

	UFUNCTION(BlueprintPure, Category="Health")
	float GetMaxHealth() const { return MaxHealth; }

	UFUNCTION(BlueprintPure, Category="Health")
	float GetHealthPercent() const;

	UFUNCTION(BlueprintPure, Category="Health")
	bool IsAlive() const { return bIsAlive; }

protected:
	virtual void BeginPlay() override;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Health")
	float MaxHealth = 100.f;

	UPROPERTY(BlueprintReadOnly, Category="Health")
	float CurrentHealth = 100.f;

	UPROPERTY(BlueprintReadOnly, Category="Health")
	bool bIsAlive = true;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Health")
	bool bInvincible = false;
};
