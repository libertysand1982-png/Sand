#pragma once

#include "CoreMinimal.h"
#include "UObject/Interface.h"
#include "SandInteractable.generated.h"

class ASandCharacter;

UINTERFACE(MinimalAPI, Blueprintable)
class USandInteractable : public UInterface
{
	GENERATED_BODY()
};

class SANDGAME_API ISandInteractable
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, BlueprintNativeEvent, Category="Interaction")
	void Interact(ASandCharacter* Interactor);

	UFUNCTION(BlueprintCallable, BlueprintNativeEvent, Category="Interaction")
	FText GetInteractPrompt() const;
};
