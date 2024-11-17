module SmartContractRSpayments::Payment {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;

    /// Error codes
    const ERR_RIDE_ALREADY_EXISTS: u64 = 1;
    const ERR_INSUFFICIENT_PAYMENT: u64 = 2;
    const ERR_UNAUTHORIZED: u64 = 3;

    /// Struct to store ride details and payment status
    struct RideDetails has key {
        driver: address,
        passenger: address,
        fare: u64,
        completed: bool,
        start_time: u64
    }

    /// Initialize a new ride with fare details
    public fun initialize_ride(
        driver: &signer,
        passenger_addr: address,
        fare_amount: u64
    ) {
        let driver_addr = signer::address_of(driver);
        
        assert!(!exists<RideDetails>(driver_addr), ERR_RIDE_ALREADY_EXISTS);
        
        let ride = RideDetails {
            driver: driver_addr,
            passenger: passenger_addr,
            fare: fare_amount,
            completed: false,
            start_time: timestamp::now_seconds()
        };
        
        move_to(driver, ride);
    }

    /// Process payment from passenger to driver
    public fun process_payment(
        passenger: &signer,
        driver_addr: address
    ) acquires RideDetails {
        let passenger_addr = signer::address_of(passenger);
        let ride = borrow_global_mut<RideDetails>(driver_addr);
        
        assert!(ride.passenger == passenger_addr, ERR_UNAUTHORIZED);
        assert!(!ride.completed, ERR_RIDE_ALREADY_EXISTS);
        
        let payment = coin::withdraw<AptosCoin>(passenger, ride.fare);
        coin::deposit(driver_addr, payment);
        
        ride.completed = true;
    }
}