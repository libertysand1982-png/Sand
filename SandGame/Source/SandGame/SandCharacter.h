#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "InputActionValue.h"
#include "SandCharacter.generated.h"

class UCameraComponent;
class USpringArmComponent;
class USandHealthComponent;
class UInputMappingContext;
class UInputAction;
class USphereComponent;

UCLASS()
class SANDGAME_API ASandCharacter : public ACharacter
{
	GENERATED_BODY()

public:
	ASandCharacter();

	virtual void Tick(float DeltaTime) override;
	virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

	UFUNCTION(BlueprintCallable, Category="Combat")
	void Attack();

	UFUNCTION(BlueprintCallable, Category="Interaction")
	void Interact();

	UFUNCTION(BlueprintPure, Category="Combat")
	bool IsAttacking() const { return bIsAttacking; }

	UFUNCTION(BlueprintPure, Category="Stats")
	int32 GetCoins() const { return Coins; }

	UFUNCTION(BlueprintCallable, Category="Stats")
	void AddCoins(int32 Amount);

	USandHealthComponent* GetHealthComponent() const { return HealthComponent; }

protected:
	virtual void BeginPlay() override;

	// --- Components ---
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Camera")
	USpringArmComponent* SpringArm;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Camera")
	UCameraComponent* FollowCamera;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Health")
	USandHealthComponent* HealthComponent;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Combat")
	USphereComponent* MeleeHitbox;

	// --- Enhanced Input ---
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Input")
	UInputMappingContext* DefaultMappingContext;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Input")
	UInputAction* MoveAction;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Input")
	UInputAction* LookAction;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Input")
	UInputAction* JumpAction;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Input")
	UInputAction* AttackAction;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Input")
	UInputAction* InteractAction;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Input")
	UInputAction* SprintAction;

	// --- Combat ---
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Combat")
	float AttackDamage = 35.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Combat")
	float AttackRange = 150.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Combat")
	float AttackCooldown = 0.6f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Combat")
	float InteractRange = 250.f;

	// --- Movement ---
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Movement")
	float WalkSpeed = 400.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Movement")
	float SprintSpeed = 700.f;

	// --- Stats ---
	UPROPERTY(BlueprintReadOnly, Category="Stats")
	int32 Coins = 0;

private:
	void Move(const FInputActionValue& Value);
	void Look(const FInputActionValue& Value);
	void StartSprint();
	void StopSprint();
	void OnAttackInput();
	void OnInteractInput();

	void PerformMeleeAttack();
	void ResetAttack();

	void OnDeath();

	bool bIsAttacking = false;
	bool bIsSprinting = false;

	FTimerHandle AttackCooldownTimer;
	FTimerHandle MeleeHitTimer;
};
