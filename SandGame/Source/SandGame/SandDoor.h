#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "SandInteractable.h"
#include "SandDoor.generated.h"

class UStaticMeshComponent;
class UBoxComponent;

UCLASS()
class SANDGAME_API ASandDoor : public AActor, public ISandInteractable
{
	GENERATED_BODY()

public:
	ASandDoor();

	virtual void Interact_Implementation(ASandCharacter* Interactor) override;
	virtual FText GetInteractPrompt_Implementation() const override;

	UFUNCTION(BlueprintCallable, Category="Door")
	void OpenDoor();

	UFUNCTION(BlueprintCallable, Category="Door")
	void CloseDoor();

	UFUNCTION(BlueprintPure, Category="Door")
	bool IsOpen() const { return bIsOpen; }

protected:
	virtual void BeginPlay() override;
	virtual void Tick(float DeltaTime) override;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Door")
	UStaticMeshComponent* DoorFrame;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Door")
	UStaticMeshComponent* DoorMesh;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Door")
	UBoxComponent* InteractTrigger;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Door")
	float OpenAngle = 90.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Door")
	float OpenSpeed = 2.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Door")
	bool bLockedByDefault = false;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Door")
	bool bRequiresKey = false;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Door", meta=(EditCondition="bRequiresKey"))
	FName KeyItemName = "OldKey";

private:
	bool bIsOpen = false;
	bool bIsMoving = false;
	float CurrentAngle = 0.f;
	float TargetAngle = 0.f;
};
