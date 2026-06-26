#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "SandInteractable.h"
#include "SandChest.generated.h"

class UStaticMeshComponent;

UCLASS()
class SANDGAME_API ASandChest : public AActor, public ISandInteractable
{
	GENERATED_BODY()

public:
	ASandChest();

	virtual void Interact_Implementation(ASandCharacter* Interactor) override;
	virtual FText GetInteractPrompt_Implementation() const override;

protected:
	virtual void BeginPlay() override;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Chest")
	UStaticMeshComponent* ChestBase;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Chest")
	UStaticMeshComponent* ChestLid;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Loot")
	int32 MinCoins = 10;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Loot")
	int32 MaxCoins = 50;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Loot")
	float HealAmount = 25.f;

	UPROPERTY(BlueprintReadOnly, Category="Chest")
	bool bIsLooted = false;

private:
	void OpenAnimation();
	FTimerHandle OpenAnimTimer;
	float LidOpenAngle = 0.f;
};
