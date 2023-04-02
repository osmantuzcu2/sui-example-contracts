

 module test_catapult::test_catapult {
    use sui::url::{Self, Url};
    use std::string;
    use std::vector;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const COLLECTION_NAME :vector<u8> =(b"Xranilec Cars");
    const DESCRIPTION : vector<u8> =(b"Xranilec Cars NFT SUI are WEB 3 cars with a blocky design. Unique, constantly rushing through the world of WEB 3");
    const COLLECTION_URI : vector<u8> =(b"https://www.xranilec-cars.com/");
    const TOKEN_NAME : vector<u8> =(b"Xranilec Cars #");
    const TOKEN_URI : vector<u8> =(b"https://bafkreie5nox2dhtwt3blixynoijxwrqrlsadhckbb3x27g7sxz7vlqksbe.ipfs.nftstorage.link/");
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
