# @version ^0.3.2
"""
@title Base Aave V3 Flash Loan Receiver
@license MIT
@author bsh98
@notice Vyper implementation of Aave V3 Flash Loans
"""

from vyper.interfaces import ERC20

# set constants to desired level
MAX_PARAMS_LEN: constant(uint256) = 32
MAX_ASSETS_LEN: constant(uint256) = 32

pool: address

@external
def __init__(_pool: address):
    """
    @notice Initialize Aave V3 Pool address
    @dev Sets value of state variable pool
    @param _pool Address of the Aave V3 pool (formerly lending pool)
    """
    self.pool = _pool

@external
def executeOperation(
    _assets: DynArray[address, MAX_ASSETS_LEN], 
    _amounts: DynArray[uint256, MAX_ASSETS_LEN], 
    _premiums: DynArray[uint256, MAX_ASSETS_LEN],
    _initiator: address, 
    _params: Bytes[MAX_PARAMS_LEN]
) -> bool: 
    """
    @notice Executes logic with borrowed assets and set approvals
    @dev This method is called by the Aave Pool
    @param _assets Addresses of each asset borrowed
    @param _amounts Amount of each asset borrowed (raw)
    @param _premiums Premium owed for each asset borrowed (raw)
    @param _initiator Address of the initiator of the flash loan
    @param _params Arbitrary params passed by the initiator
    @return True if execution success
    """
    # conduct logic
    # ...

    # approve transfer back to pool
    for i in range(MAX_ASSETS_LEN):
        if i >= len(_assets):
            break
        amount_owed: uint256 = _amounts[i] + _premiums[i]
        ERC20(_assets[i]).approve(self.pool, amount_owed)      

    return True

@external
def flash_call(
    _assets: DynArray[address, MAX_ASSETS_LEN],
    _amounts: DynArray[uint256, MAX_ASSETS_LEN],
    _interest_rate_modes: DynArray[uint256, MAX_ASSETS_LEN],
    _params: Bytes[MAX_PARAMS_LEN],
    _referral_code: Bytes[2]
):
    """
    @notice Make flash loan call to pool
    @dev Uses raw_call, since uint16 is not supported in vyper
    @param _assets Addresses of assets to borrow
    @param _amounts Amount of each asset to borrow (raw)
    @param _interest_rate_modes 0=no debt, 1=stable, 2=variable
    @param _params Arbitrary params to pass to the receiver
    @param _referral_code Optional Aave referral code
    """
    receiver_address: address = self
    on_behalf_of: address = self
    
    raw_call(
        self.pool,
        _abi_encode(
            receiver_address,
            _assets,
            _amounts,
            _interest_rate_modes,
            on_behalf_of,
            _params,
            _referral_code,
            method_id=method_id("flashLoan(address,address[],uint256[],uint256[],address,bytes,uint16)")
        )
    )
