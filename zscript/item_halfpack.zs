// ------------------------------------------------------------
// Light Backpack aka Half-Pack
// ------------------------------------------------------------

//const HDCONST_BPMAX=1000;

class HDHalfPack : HDBackpack{
	override string, double GetPickupSprite() { return "HPAKA0", 1.0; }
    override double WeaponBulk() { return max((Storage ? Storage.TotalBulk * 0.70 : 0), 50); }

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl){
		int BaseOffset = -80;

		sb.DrawString(sb.pSmallFont, "\c[DarkBrown][] [] [] \c[Tan]Light Backpack\c[DarkBrown][] [] []", (0, BaseOffset), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
		sb.DrawString(sb.pSmallFont, "Total Bulk: \cf"..int(Storage.TotalBulk).."\c-", (0, BaseOffset + 10), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);

		int ItemCount = Storage.Items.Size();

		if(!ItemCount){
			sb.DrawString(sb.pSmallFont, "No items found.", (0, BaseOffset + 30), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_DARKGRAY);
			return;
		}

		StorageItem SelItem = Storage.GetSelectedItem();
		if(!SelItem)return;

		for(int i = 0; i < (ItemCount > 1 ? 5 : 1); ++i){
			int RealIndex = (Storage.SelItemIndex + (i - 2)) % ItemCount;
			if (RealIndex < 0)
			{
				RealIndex = ItemCount - abs(RealIndex);
			}

			vector2 Offset = ItemCount > 1 ? (-100, 8) : (0, 0);
			switch (i)
			{
				case 1: Offset = (-50, 4);  break;
				case 2: Offset = (0, 0); break;
				case 3: Offset = (50, 4); break;
				case 4: Offset = (100, 8); break;
			}

			StorageItem CurItem = Storage.Items[RealIndex];
			bool CenterItem = Offset ~== (0, 0);
			sb.DrawImage(CurItem.Icons[0], (Offset.x, BaseOffset + 40 + Offset.y), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, CenterItem && !CurItem.HaveNone() ? 1.0 : 0.6, CenterItem ? (50, 30) : (30, 20), getdefaultbytype(CurItem.ItemClass).scale*(CenterItem?4.0:3.0));
		}

		sb.DrawString(sb.pSmallFont, SelItem.NiceName, (0, BaseOffset + 60), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_FIRE);

		int AmountInBackpack = SelItem.ItemClass is 'HDMagAmmo' ? SelItem.Amounts.Size() : (SelItem.Amounts.Size() > 0 ? SelItem.Amounts[0] : 0);
		sb.DrawString(sb.pSmallFont, "In backpack:  "..sb.FormatNumber(AmountInBackpack, 1, 6), (0, BaseOffset + 70), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, AmountInBackpack > 0 ? Font.CR_BROWN : Font.CR_DARKBROWN);

		int AmountOnPerson = GetAmountOnPerson(hpl.FindInventory(SelItem.ItemClass));
		sb.DrawString(sb.pSmallFont, "On person:  "..sb.FormatNumber(AmountOnPerson, 1, 6), (0, BaseOffset + 78), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, AmountOnPerson > 0 ?  Font.CR_WHITE : Font.CR_DARKGRAY);

		// [Ace] Don't display the first item. It's already in the preview.
		if (SelItem.ItemClass is 'HDArmour')
		{
			for (int i = 1; i < SelItem.Amounts.Size(); ++i)
			{
				vector2 Off = (-140 + 35 * ((i - 1) % 8), BaseOffset + 110 + 35 * ((i - 1) / 8));
				sb.DrawImage(SelItem.Icons[i], Off, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, 1.0, (30, 20), (4.0, 4.0));
			}
		}
		else if (SelItem.ItemClass is 'HDMagAmmo' && !(SelItem.ItemClass is 'HDInjectorMaker'))
		{
			for (int i = 1; i < SelItem.Amounts.Size(); ++i)
			{
				vector2 Off = (-140 + 20 * ((i - 1) / 10) - 2 * ((i - 1) % 10), BaseOffset + 110 + 10 * ((i - 1) % 10));
				sb.DrawImage(SelItem.Icons[i], Off, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, 1.0, (16, 16), (4.0, 4.0));
			}
		}
		else if (SelItem.ItemClass is 'HDWeapon' && SelItem.Amounts.Size() > 0 && SelItem.Amounts[0] > 1)
		{
			for (int i = 1; i < SelItem.Amounts[0]; ++i)
			{
				vector2 Off = (-120 + 60 * ((i - 1) % 5), BaseOffset + 110 + 30 * ((i - 1) / 5));
				sb.DrawImage(SelItem.Icons[i], Off, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, 1.0, (50, 20), (4.0, 4.0));
			}
		}
	}
	
	Default{
	/*
		+INVENTORY.INVBAR
		+WEAPON.WIMPY_WEAPON
		+WEAPON.NO_AUTO_SWITCH
		+HDWEAPON.DROPTRANSLATION
		+HDWEAPON.FITSINBACKPACK
		+HDWEAPON.ALWAYSSHOWSTATUS
		+HDWEAPON.IGNORELOADOUTAMOUNT
		+hdweapon.hinderlegs
	*/
	
		Weapon.SelectionOrder 1005;
		Inventory.Icon "HPAKA0";
		Inventory.PickupMessage "Picked up a light backpack!";
		Inventory.PickupSound "weapons/pocket";
		Tag "Light Backpack";
		HDWeapon.RefId "hpk";
		HDBackpack.MaxCapacity HDCONST_BPMAX/2;
		HDWeapon.wornlayer STRIP_BACKPACK;
	}
	States{
	Spawn:
		HPAK ABC -1 NoDelay{
			if (invoker.Storage.TotalBulk ~== 0)
			{
				frame = 1;
			}
			else if (target)
			{
				translation = target.translation;
				frame = 2;
			}
			invoker.bNO_AUTO_SWITCH = false;
		}
		Stop;
	Select0:
		TNT1 A 10{
			A_UpdateStorage(); // [Ace] Populates items.
			A_StartSound("weapons/pocket", CHAN_WEAPON);
			if (invoker.Storage.TotalBulk > (HDCONST_BPMAX/2 * 0.7))
			{
				A_SetTics(20);
			}
		}
		TNT1 A 0 A_Raise(999);
		Wait;
	Deselect0:
		TNT1 A 0 A_Lower(999);
		Wait;
	Ready:
		TNT1 A 1 A_BPReady();
		Goto ReadyEnd;
	User3:
		TNT1 A 0{
			StorageItem si = invoker.Storage.GetSelectedItem();
			if (si && si.ItemClass is 'HDMagAmmo')
			{
				let mag = GetDefaultByType((class<HDMagAmmo>)(si.ItemClass));
				if(
					mag.MustShowInMagManager
					||mag.RoundType!=""
				){
					A_MagManager(mag.GetClassName());
				}else{
					A_SelectWeapon("PickupManager");
				}
			}else{
				A_SelectWeapon("PickupManager");
			}
		}
		Goto Ready;
	}
}

//semi-filled half-packs at random

//make these spawnable later
class WildHalfPack:IdleDummy{
		//$Category "Items/Hideous Destructor/Gear"
		//$Title "Light Backpack (Random Spawn)"
		//$Sprite "HPAKC0"
	override void postbeginplay(){
		super.postbeginplay();
		let aaa=HDHalfPack(spawn("HDHalfPack",pos,ALLOW_REPLACE));
		aaa.RandomContents();
		destroy();
	}
}

class HalfPack_Spawner : EventHandler
{

override void CheckReplacement(ReplaceEvent HalfPack) {
	switch (HalfPack.Replacee.GetClassName()) {

  case 'WildBackpack' 	:   if (!random(0,9))HalfPack.Replacement = "WildHalfPack";
                            break;

		}

	HalfPack.IsFinal = false;
	}
}


