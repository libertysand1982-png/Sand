#include "SandChest.h"
#include "SandCharacter.h"
#include "SandHealthComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Kismet/KismetMathLibrary.h"

ASandChest::ASandChest()
{
	PrimaryActorTick.bCanEverTick = true;

	ChestBase = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("ChestBase"));
	RootComponent = ChestBase;

	ChestLid = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("ChestLid"));
	ChestLid->SetupAttachment(ChestBase);
	ChestLid->SetRelativeLocation(FVector(0.f, 0.f, 25.f));
}

void ASandChest::BeginPlay()
{
	Super::BeginPlay();
}

void ASandChest::Interact_Implementation(ASandCharacter* Interactor)
{
	if (bIsLooted || !Interactor)
		return;

	bIsLooted = true;

	// Give coins
	const int32 CoinAmount = FMath::RandRange(MinCoins, MaxCoins);
	Interactor->AddCoins(CoinAmount);

	// Heal player
	if (HealAmount > 0.f)
	{
		Interactor->GetHealthComponent()->Heal(HealAmount);
	}

	// Play open animation
	OpenAnimation();
}

FText ASandChest::GetInteractPrompt_Implementation() const
{
	return bIsLooted
		? FText::FromString(TEXT("(Vide)"))
		: FText::FromString(TEXT("Ouvrir le coffre"));
}

void ASandChest::OpenAnimation()
{
	// Animate lid rotating to 90 degrees
	FTimerDelegate Delegate;
	Delegate.BindLambda([this]()
	{
		LidOpenAngle = FMath::FInterpTo(LidOpenAngle, 90.f, 0.05f, 5.f);
		ChestLid->SetRelativeRotation(FRotator(-LidOpenAngle, 0.f, 0.f));
		if (LidOpenAngle >= 89.f)
		{
			GetWorld()->GetTimerManager().ClearTimer(OpenAnimTimer);
		}
	});
	GetWorld()->GetTimerManager().SetTimer(OpenAnimTimer, Delegate, 0.05f, true);
}
