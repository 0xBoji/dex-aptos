module aptosswap::utils {
    use std::vector;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;
    use aptos_std::type_info;
    use aptos_framework::account;

    const SECONDS_PER_DAY: u64 = 86400;
    const MILLISECONDS_PER_DAY: u64 = SECONDS_PER_DAY * 1000;

    /// Not enough balance for operation
    const ENOT_ENOUGH_BALANCE: u64 = 1;

    public fun get_epoch(): u64 {
        timestamp::now_microseconds() / (MILLISECONDS_PER_DAY * 1000)
    }

    public fun merge_coins<CoinType>(coins: vector<coin::Coin<CoinType>>): coin::Coin<CoinType> {
        let result = coin::zero<CoinType>();
        while (!vector::is_empty(&coins)) {
            let coin = vector::pop_back(&mut coins);
            coin::merge(&mut result, coin);
        };
        vector::destroy_empty(coins);
        result
    }

    public fun merge_coins_to_amount_and_transfer_back_rest<CoinType>(
        coins: vector<coin::Coin<CoinType>>,
        amount: u64
    ): (coin::Coin<CoinType>, coin::Coin<CoinType>) {
        let merged = merge_coins(coins);
        assert!(coin::value(&merged) >= amount, ENOT_ENOUGH_BALANCE);
        
        let to_return = coin::extract(&mut merged, amount);
        (to_return, merged)
    }

    public fun transfer_or_destroy_zero<CoinType>(c: coin::Coin<CoinType>, addr: address) {
        if (coin::value(&c) > 0) {
            coin::deposit(addr, c);
        } else {
            coin::destroy_zero(c);
        }
    }

    public fun mint_to(amount: u64, recipient: address) acquires AptosCoin {
        let coins = coin::mint<AptosCoin>(amount, &aptos_framework::aptos_coin::AptosCoin);
        coin::deposit(recipient, coins);
    }

    // Note: Aptos doesn't have a direct equivalent to Aptos's Balance type.
    // You might need to implement custom logic for partial balance operations.

    #[test(owner = @0x1)]
    public entry fun test_merge_coins_to_amount_and_transfer_back_rest(owner: &signer) {
        let type_info = type_info::type_of<AptosCoin>();
        aptos_framework::aptos_coin::initialize_for_test(owner);
        
        let coins = vector::empty<coin::Coin<AptosCoin>>();
        vector::push_back(&mut coins, coin::mint<AptosCoin>(500, &aptos_framework::aptos_coin::AptosCoin));
        vector::push_back(&mut coins, coin::mint<AptosCoin>(300, &aptos_framework::aptos_coin::AptosCoin));
        vector::push_back(&mut coins, coin::mint<AptosCoin>(200, &aptos_framework::aptos_coin::AptosCoin));

        let (extracted, rest) = merge_coins_to_amount_and_transfer_back_rest(coins, 700);
        assert!(coin::value(&extracted) == 700, 1);
        assert!(coin::value(&rest) == 300, 2);

        coin::destroy_burn_cap(aptos_framework::aptos_coin::remove_burn_capability(owner));
        coin::destroy_mint_cap(aptos_framework::aptos_coin::remove_mint_capability(owner));
    }
}