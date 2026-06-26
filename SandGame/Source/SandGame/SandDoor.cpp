#include "SandDoor.h"
#include "SandCharacter.h"
#include "Components/StaticMeshComponent.h"
#include "Components/BoxComponent.h"

ASandDoor::ASandDoor()
{
	PrimaryActorTick.bCanEverTick = true;

	DoorFrame = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("DoorFrame"));
	RootComponent = DoorFrame;
	DoorFrame->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);

	DoorMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("DoorMesh"));
	DoorMesh->SetupAttachment(DoorFrame);
	DoorMesh->SetRelativeLocation(FVector(0.f, 50.f, 0.f)); // pivot offset

	InteractTrigger = CreateDefaultSubobject<UBoxComponent>(TEXT("InteractTrigger"));
	InteractTrigger->SetupAttachment(RootComponent);
	InteractTrigger->SetBoxExtent(FVector(80.f, 80.f, 120.f));
	InteractTrigger->SetCollisionEnabled(ECollisionEnabled::QueryOnly);
	InteractTrigger->SetCollisionResponseToAllChannels(ECR_Ignore);
	InteractTrigger->SetCollisionResponseToChannel(ECC_Pawn, ECR_Overlap);
}

void ASandDoor::BeginPlay()
{
	Super::BeginPlay();
	TargetAngle = 0.f;
	CurrentAngle = 0.f;
}

void ASandDoor::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	if (!bIsMoving)
		return;

	CurrentAngle = FMath::FInterpTo(CurrentAngle, TargetAngle, DeltaTime, OpenSpeed);

	if (FMath::IsNearlyEqual(CurrentAngle, TargetAngle, 0.5f))
	{
		CurrentAngle = TargetAngle;
		bIsMoving = false;
	}

	DoorMesh->SetRelativeRotation(FRotator(0.f, CurrentAngle, 0.f));
}

void ASandDoor::Interact_Implementation(ASandCharacter* Interactor)
{
	if (bRequiresKey)
	{
		// In a full game, check inventory here
		// For now, always open
	}

	if (bIsOpen)
		CloseDoor();
	else
		OpenDoor();
}

FText ASandDoor::GetInteractPrompt_Implementation() const
{
	if (bRequiresKey && !bIsOpen)
		return FText::FromString(TEXT("Ouvrir (clé requise)"));
	return bIsOpen ? FText::FromString(TEXT("Fermer")) : FText::FromString(TEXT("Ouvrir"));
}

void ASandDoor::OpenDoor()
{
	if (bIsOpen)
		return;
	bIsOpen = true;
	TargetAngle = OpenAngle;
	bIsMoving = true;
}

void ASandDoor::CloseDoor()
{
	if (!bIsOpen)
		return;
	bIsOpen = false;
	TargetAngle = 0.f;
	bIsMoving = true;
}
