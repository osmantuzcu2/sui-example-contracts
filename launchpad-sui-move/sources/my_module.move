

 module test_catapult::test_catapult {
    use sui::url::{Self, Url};
    use std::string;
    use std::vector;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const COLLECTION_NAME :vector<u8> =(b"Dwarflings");
    const DESCRIPTION : vector<u8> =(b"Dwarflings is the utility collection of the Catapult NFT Launchpad");
    const COLLECTION_URI : vector<u8> =(b"https://dwarfknights.com/");
    const TOKEN_NAME : vector<u8> =(b"Dwarflings #");
    const TOKEN_URI : vector<u8> =(b"https://bafybeifaakteej3rjh5lq326pl2nfbu5iwzww4vzjzqvrx3tksgys5n7ty.ipfs.nftstorage.link/");
    const MAX_PER_WL: u64 = 3;
    const MAX_SUPPLY: u64 = 111;

    struct TestNFT has key, store {
        id: UID,
        name: string::String,
        description: string::String,
        url: Url,
    }

    struct MintNFTEvent has copy, drop {
        object_id: ID,
        creator: address,
        name: string::String,
    }

    struct Counter has key {
        id: UID,
        value: u64,
    }
    fun init(ctx: &mut TxContext) {
        transfer::share_object(
            Counter {
                id: object::new(ctx),
                value: 1,
            }
        )
    }

    public entry fun mint (     
        counter: &mut Counter,  
        ctx: &mut TxContext
    ) {
        
        let c_ref:u64 = counter.value;
        let tname= append_num_str(string::utf8(TOKEN_NAME),c_ref);
        let nft = TestNFT {
            id: object::new(ctx),
            name: tname,
            description: string::utf8(DESCRIPTION),
            url: url::new_unsafe_from_bytes(TOKEN_URI)
        };
        let sender = tx_context::sender(ctx);
        event::emit(MintNFTEvent {
            object_id: object::uid_to_inner(&nft.id),
            creator: sender,
            name: nft.name,
        });
        counter.value = c_ref + 1;
        transfer::transfer(nft, sender);
    }
    fun append_num_str(str:string::String,num: u64) : string::String{
        let a=num_str(num);
        string::append( &mut str,a);
        str
    }
    fun num_str(num: u64): string::String{
        let v1 = vector::empty();
        while (num/10 > 0){
            let rem = num%10;
            vector::push_back(&mut v1, ((rem+48) as u8));
            num = num/10;
        };
        vector::push_back(&mut v1, ((num+48) as u8));
        vector::reverse(&mut v1);
        string::utf8(v1)
    }

    public entry fun update_description(
        nft: &mut TestNFT,
        new_description: vector<u8>,
        _: &mut TxContext
    ) {
        nft.description = string::utf8(new_description)
    }

    public entry fun burn(nft: TestNFT, _: &mut TxContext) {
        let TestNFT { id, name: _, description: _, url: _ } = nft;
        object::delete(id)
    }

    public fun name(nft: &TestNFT): &string::String {
        &nft.name
    }

    public fun description(nft: &TestNFT): &string::String {
        &nft.description
    }

    public fun url(nft: &TestNFT): &Url {
        &nft.url
    }
    fun increment_counter(counter: &mut Counter) {
        counter.value = counter.value + 1
    }
} 

/*  module move_test_code::shared_objects_version {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct Counter has key {
        id: UID,
        value: u64,
    }
    

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            Counter {
                id: object::new(ctx),
                value: 0,
            },
            tx_context::sender(ctx),
        )
    }

    public entry fun create_shared_counter(ctx: &mut TxContext) {
        transfer::share_object(Counter {
            id: object::new(ctx),
            value: 0,
        })
    }

    public entry fun share_counter(counter: Counter) {
        transfer::share_object(counter)
    }

    public entry fun increment_counter(counter: &mut Counter) {
        counter.value = counter.value + 1
    }
}  */
/* module nftGame::GoblinSuiWarriorNFT {
    use std::string;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::hash;
    use std::vector;
    use std::option::{Self, Option};

    /// Structs
    struct Ownership has key {
        id: UID
    }

    struct NFTGlobalData has key {
        id: UID,
        maxWarriorSupply: u64,
        mintedWarriors: u64,
        baseWarriorURL: string::String,
        baseWeaponURL: string::String,
        mintingEnabled: bool,
        owner: address,
        mintedAddresses: vector<address>
    }

    struct GoblinSuiWarriorNFT has key {
        id: UID,
        index: u64,
        name: string::String,
        baseAttackPower: u64,
        baseSpellPower: u64,
        baseHealthPoints: u64,
        experiencePoints: u64,
        url: string::String,
        equippedWeapon: Option<Weapon>
    }

    struct Weapon has key, store {
        id: UID,
        name: string::String,
        attackPower: u64,
        spellPower: u64,
        healthPoints: u64,
        url: string::String
    }

    struct Boss has key {
        id: UID,
        name: string::String,
        attackPower: u64,
        spellPower: u64,
        healthPoints: u64,
        experiencePointsReward: u64,
        url: string::String
    }


    /// Initializer
    fun init(ctx: &mut TxContext) {

        let ownership = Ownership {
            id: object::new(ctx)
        };

        let nftGlobalData = NFTGlobalData {
            id: object::new(ctx),
            maxWarriorSupply: 10000,
            mintedWarriors: 0,
            baseWarriorURL: string::utf8(b"https://ipfs.io/ipfs/QmSrgtDKdUw4a9GVxWH3fSiVnFKX4ivtwvkZZiopWSwLNW/"),
            baseWeaponURL: string::utf8(b"https://ipfs.io/ipfs/QmUPTXn9KrK3x5dD4x2RH3t2fNk7LgUUjVyygR7CsPyk6L/"),
            mintingEnabled: true,
            owner: tx_context::sender(ctx),
            mintedAddresses: vector::empty()
        };

        transfer::share_object(nftGlobalData);
        transfer::transfer(ownership, tx_context::sender(ctx));
    }


    /// Owner Functions
    entry fun changeMintingStatus(flag: bool, globalData: &mut NFTGlobalData, ctx: &mut TxContext) {
        assert!(globalData.owner == tx_context::sender(ctx), 0);
        globalData.mintingEnabled = flag;
    }

    entry fun mintBoss(_ownership: &Ownership, name: vector<u8>, attackPower: u64, spellPower: u64, healthPoints: u64, experiencePointsRewards: u64, url: vector<u8>, ctx: &mut TxContext){
        let boss = Boss {
            id: object::new(ctx),
            name: string::utf8(name),
            attackPower,
            spellPower,
            healthPoints,
            experiencePointsReward: experiencePointsRewards,
            url: string::utf8(url)
        };

        transfer::share_object(boss);
    }


    /// Getters
    public fun name(nft: &GoblinSuiWarriorNFT): &string::String {
        &nft.name
    }

    public fun url(nft: &GoblinSuiWarriorNFT): &string::String {
        &nft.url
    }

    public fun warriorBaseAttackPower(nft: &GoblinSuiWarriorNFT): u64 {
        nft.baseAttackPower
    }

    public fun warriorBaseSpellPower(nft: &GoblinSuiWarriorNFT): u64 {
        nft.baseSpellPower
    }

    public fun warriorBaseHealthPoints(nft: &GoblinSuiWarriorNFT): u64 {
        nft.baseHealthPoints
    }

    public fun weaponAttackPower(weapon: &Weapon): u64 {
        weapon.attackPower
    }

    public fun weaponSpellPower(weapon: &Weapon): u64 {
        weapon.spellPower
    }

    public fun weaponHealthPoints(weapon: &Weapon): u64 {
        weapon.healthPoints
    }


    /// Since blockchains are deterministic there would need to be an oracle
    /// for random number generators such as Chainlink or API3's QRNG
    /// Since none such exist for Sui at the moment, we've implemented two very
    /// basic non random number generators based on the hashing of a seed and in the
    /// current timestamp (epoch is changed once per day and it's the only 
    /// timestamp-like feature usable in Sui at this point)
    /// Note: This is demonstrational only and is not intended to be used
    /// on the mainnet as it is exploitable
    fun randArrayGenerator(seed: vector<u8>) : vector<u8> {
        hash::sha2_256(seed)
    }
    fun randNumber(ctx: &mut TxContext) : u64 {
        tx_context::epoch(ctx)
    }


    /// Minting Functions
    entry fun mintWarrior(globalData: &mut NFTGlobalData, name: vector<u8>, ctx: &mut TxContext) {
        assert!(globalData.mintingEnabled, 0);
        assert!(globalData.mintedWarriors < globalData.maxWarriorSupply, 0);
        assert!(vector::length(&name) >= 3, 0);
        let sender = tx_context::sender(ctx);
        let randArray = randArrayGenerator(name);
        assert!(vector::contains(&globalData.mintedAddresses, &sender) == false, 0);
        assert!(vector::length(&randArray) >= 3, 0);

        let nft = GoblinSuiWarriorNFT {
            id: object::new(ctx),
            index: globalData.mintedWarriors,
            name: string::utf8(name),
            baseAttackPower: (*vector::borrow(&randArray, 0) as u64)*2,
            baseSpellPower: (*vector::borrow(&randArray, 1) as u64)*2,
            baseHealthPoints: (*vector::borrow(&randArray, 2) as u64)*2,
            experiencePoints: 0,
            url: globalData.baseWarriorURL,
            equippedWeapon: option::none(),
        };

        globalData.mintedWarriors = globalData.mintedWarriors + 1;

        vector::push_back(&mut globalData.mintedAddresses, sender);
        transfer::transfer(nft, sender);
    }

    entry fun mintWeapon(globalData: &mut NFTGlobalData, name: vector<u8>, ctx: &mut TxContext) {
        assert!(globalData.mintingEnabled, 0);
        assert!(vector::length(&name) >= 3, 0);
        let sender = tx_context::sender(ctx);
        let randArray = randArrayGenerator(name);
        assert!(vector::length(&randArray) >= 3, 0);

        let weapon = Weapon {
            id: object::new(ctx),
            name: string::utf8(name),
            attackPower: (*vector::borrow(&randArray, 0) as u64)*2,
            spellPower: (*vector::borrow(&randArray, 1) as u64)*2,
            healthPoints: (*vector::borrow(&randArray, 2) as u64)*2,
            url: globalData.baseWeaponURL
        };

        transfer::transfer(weapon, sender);
    }

    
    /// Game Logic
    entry fun battleAgainstBoss(boss: &Boss, nft: &mut GoblinSuiWarriorNFT, ctx: &mut TxContext){
        let playerWon;
        let playerHp = nft.baseHealthPoints;
        let playerAttack = nft.baseAttackPower + nft.baseSpellPower;

        if(option::is_some(&nft.equippedWeapon)) {
            let equippedWeapon = option::borrow(&nft.equippedWeapon);
            playerAttack = playerAttack + equippedWeapon.attackPower + equippedWeapon.spellPower;
            playerHp = playerHp + equippedWeapon.healthPoints;
        };

        let bosshp = boss.healthPoints;
        let bossAttack = boss.attackPower + boss.spellPower;

        if(playerAttack > bosshp - 20){
            bosshp = 20; 
        }
        else {
            bosshp = bosshp - playerAttack;
        };

        if(bossAttack > playerHp - 20){
            playerHp = 20; 
        }
        else {
            playerHp = playerHp - bossAttack;
        };

        let totalHP = bosshp + playerHp;
        let rand = randNumber(ctx);
        let result = rand % totalHP;

        if(bosshp > playerHp){
            if(result <= playerHp){
                playerWon = true;
            }
            else {
                playerWon = false;
            }
        }
        else {
            if(result <= bosshp){
                playerWon = false;
            }
            else {
                playerWon = true;
            }
        };

        if(playerWon){
            nft.experiencePoints = nft.experiencePoints + boss.experiencePointsReward;
        };
    }
    
    entry fun useExperiencePoints(nft: &mut GoblinSuiWarriorNFT, attackPowerPoints: u64, spellPowerPoints: u64, healthPoints: u64) {
        assert!(nft.experiencePoints >= attackPowerPoints + spellPowerPoints + healthPoints, 0);
        nft.experiencePoints = nft.experiencePoints - attackPowerPoints - spellPowerPoints - healthPoints;
        nft.baseHealthPoints = nft.baseHealthPoints + healthPoints;
        nft.baseAttackPower = nft.baseAttackPower + attackPowerPoints;
        nft.baseSpellPower = nft.baseSpellPower + spellPowerPoints;
    }

    entry fun equipWeapon(nft: &mut GoblinSuiWarriorNFT, weapon: Weapon){
        assert!(!option::is_some(&nft.equippedWeapon),0);
        option::fill(&mut nft.equippedWeapon, weapon);
    }

    entry fun unequipWeapon(nft: &mut GoblinSuiWarriorNFT, ctx: &mut TxContext) {
        assert!(option::is_some(&nft.equippedWeapon),0);
        let weapon = option::extract(&mut nft.equippedWeapon);
        transfer::transfer(weapon, tx_context::sender(ctx));
    }


    /// Transfer & Burning Functions
    entry fun transferWarrior(globalData: &NFTGlobalData, nft: GoblinSuiWarriorNFT, recipient: address, _: &mut TxContext) {
        assert!(!vector::contains(&globalData.mintedAddresses, &recipient), 0);
        transfer::transfer(nft, recipient)
    }

    entry fun transferWeapon(weapon: Weapon, recipient: address, _: &mut TxContext) {
        transfer::transfer(weapon, recipient)
    }

    entry fun burnWarrior(nft: GoblinSuiWarriorNFT) {
        let GoblinSuiWarriorNFT { id, index: _, name: _, baseAttackPower: _, baseSpellPower: _, baseHealthPoints: _, experiencePoints: _, url: _, equippedWeapon } = nft;
        object::delete(id);
        let weapon = option::destroy_some(equippedWeapon);
        let Weapon { id, name: _, attackPower: _, spellPower: _, healthPoints: _, url: _ } = weapon;
        object::delete(id);
    }

    entry fun burnWeapon(weapon: Weapon) {
        let Weapon { id, name: _, attackPower: _, spellPower: _, healthPoints: _, url: _ } = weapon;
        object::delete(id)
    }

    entry fun burnBoss(boss: Boss, _ownership: &Ownership) {
        let Boss {
            id,
            name: _,
            attackPower: _,
            spellPower: _,
            healthPoints: _,
            experiencePointsReward: _,
            url: _
        } = boss;

        object::delete(id);
    }

} */

/*     module test_nft::test_nft {
        use sui::url::{Self, Url};
        use std::string;
        use sui::object::{Self, ID, UID};
        use sui::event;
        use sui::transfer;
        use sui::tx_context::{Self, TxContext};

        /// An example NFT that can be minted by anybody
        struct TestNFT has key, store {
            id: UID,
            /// Name for the token
            name: string::String,
            /// Description of the token
            description: string::String,
            /// URL for the token
            url: Url,
            // TODO: allow custom attributes
        }

        // ===== Events =====

        struct NFTMinted has copy, drop {
            // The Object ID of the NFT
            object_id: ID,
            // The creator of the NFT
            creator: address,
            // The name of the NFT
            name: string::String,
        }

        // ===== Public view functions =====

        /// Get the NFT's `name`
        public fun name(nft: &TestNFT): &string::String {
            &nft.name
        }

        /// Get the NFT's `description`
        public fun description(nft: &TestNFT): &string::String {
            &nft.description
        }

        /// Get the NFT's `url`
        public fun url(nft: &TestNFT): &Url {
            &nft.url
        }

        // ===== Entrypoints =====

        /// Create a new devnet_nft
        public entry fun mint_to_sender(
            name: vector<u8>,
            description: vector<u8>,
            url: vector<u8>,
            ctx: &mut TxContext
        ) {
            let sender = tx_context::sender(ctx);
            let nft = TestNFT {
                id: object::new(ctx),
                name: string::utf8(name),
                description: string::utf8(description),
                url: url::new_unsafe_from_bytes(url)
            };

            event::emit(NFTMinted {
                object_id: object::id(&nft),
                creator: sender,
                name: nft.name,
            });

            transfer::transfer(nft, sender);
        }

        /// Transfer `nft` to `recipient`
        public entry fun transfer(
            nft: TestNFT, recipient: address, _: &mut TxContext
        ) {
            transfer::transfer(nft, recipient)
        }

        /// Update the `description` of `nft` to `new_description`
        public entry fun update_description(
            nft: &mut TestNFT,
            new_description: vector<u8>,
            _: &mut TxContext
        ) {
            nft.description = string::utf8(new_description)
        }

        /// Permanently delete `nft`
        public entry fun burn(nft: TestNFT, _: &mut TxContext) {
            let TestNFT { id, name: _, description: _, url: _ } = nft;
            object::delete(id)
        }
    } */
/* module my_first_package2::my_module2 {
    // Part 1: imports
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // Part 2: struct definitions
    struct Sword has key, store {
        id: UID,
        magic: u64,
        strength: u64,
    }

    struct Forge has key, store {
        id: UID,
        swords_created: u64,
    }

    // Part 3: module initializer to be executed when this module is published
    fun init(ctx: &mut TxContext) {
        let admin = Forge {
            id: object::new(ctx),
            swords_created: 0,
        };
        // transfer the forge object to the module/package publisher
        transfer::transfer(admin, tx_context::sender(ctx));
    }

    // Part 4: accessors required to read the struct attributes
    public fun magic(self: &Sword): u64 {
        self.magic
    }

    public fun strength(self: &Sword): u64 {
        self.strength
    }

    public fun swords_created(self: &Forge): u64 {
        self.swords_created
    }

    // part 5: public/ entry functions (introduced later in the tutorial)
    // part 6: private functions (if any)
} */