#include "SandPlayerController.h"
#include "Blueprint/UserWidget.h"
#include "Kismet/GameplayStatics.h"

ASandPlayerController::ASandPlayerController()
{
}

void ASandPlayerController::BeginPlay()
{
	Super::BeginPlay();

	SetShowMouseCursor(false);
	SetInputMode(FInputModeGameOnly());

	if (HUDWidgetClass)
	{
		HUDWidget = CreateWidget<UUserWidget>(this, HUDWidgetClass);
		if (HUDWidget)
			HUDWidget->AddToViewport();
	}
}

void ASandPlayerController::SetupInputComponent()
{
	Super::SetupInputComponent();

	if (InputComponent)
	{
		InputComponent->BindAction("Pause", IE_Pressed, this,
			&ASandPlayerController::TogglePause);
	}
}

void ASandPlayerController::TogglePause()
{
	if (bIsPaused)
		HidePauseMenu();
	else
		ShowPauseMenu();
}

void ASandPlayerController::ShowGameOverScreen()
{
	if (!GameOverWidgetClass)
		return;

	UUserWidget* Widget = CreateWidget<UUserWidget>(this, GameOverWidgetClass);
	if (Widget)
	{
		Widget->AddToViewport(10);
		SetShowMouseCursor(true);
		SetInputMode(FInputModeUIOnly());
	}
}

void ASandPlayerController::ShowWinScreen()
{
	if (!WinWidgetClass)
		return;

	UUserWidget* Widget = CreateWidget<UUserWidget>(this, WinWidgetClass);
	if (Widget)
	{
		Widget->AddToViewport(10);
		SetShowMouseCursor(true);
		SetInputMode(FInputModeUIOnly());
	}
}

void ASandPlayerController::ShowPauseMenu()
{
	if (!PauseMenuWidgetClass || bIsPaused)
		return;

	bIsPaused = true;
	UGameplayStatics::SetGamePaused(GetWorld(), true);

	UUserWidget* Widget = CreateWidget<UUserWidget>(this, PauseMenuWidgetClass);
	if (Widget)
	{
		Widget->AddToViewport(5);
		SetShowMouseCursor(true);
		SetInputMode(FInputModeUIOnly());
	}
}

void ASandPlayerController::HidePauseMenu()
{
	bIsPaused = false;
	UGameplayStatics::SetGamePaused(GetWorld(), false);
	SetShowMouseCursor(false);
	SetInputMode(FInputModeGameOnly());
}
