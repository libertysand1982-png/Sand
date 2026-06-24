#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "SandPlayerController.generated.h"

UCLASS()
class SANDGAME_API ASandPlayerController : public APlayerController
{
	GENERATED_BODY()

public:
	ASandPlayerController();

	UFUNCTION(BlueprintCallable, Category="UI")
	void ShowGameOverScreen();

	UFUNCTION(BlueprintCallable, Category="UI")
	void ShowWinScreen();

	UFUNCTION(BlueprintCallable, Category="UI")
	void ShowPauseMenu();

	UFUNCTION(BlueprintCallable, Category="UI")
	void HidePauseMenu();

	UFUNCTION(BlueprintCallable, Category="UI")
	bool IsGamePaused() const { return bIsPaused; }

protected:
	virtual void BeginPlay() override;
	virtual void SetupInputComponent() override;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="UI")
	TSubclassOf<class UUserWidget> HUDWidgetClass;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="UI")
	TSubclassOf<class UUserWidget> GameOverWidgetClass;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="UI")
	TSubclassOf<class UUserWidget> WinWidgetClass;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="UI")
	TSubclassOf<class UUserWidget> PauseMenuWidgetClass;

	UPROPERTY(BlueprintReadOnly, Category="UI")
	class UUserWidget* HUDWidget;

private:
	void TogglePause();
	bool bIsPaused = false;
};
