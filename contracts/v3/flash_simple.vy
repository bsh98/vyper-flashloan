# @version ^0.3.3
"""
@title Base Aave V3 Flash Loan Simple Receiver
@license MIT
@author bsh98
@notice Vyper implementation of Aave V3 Flash Loan Simple
"""

from vyper.interfaces import ERC20

# set constants to desired level
MAX_PARAMS_LEN: constant(uint256) = 32
MAX_ASSETS_LEN: constant(uint256) = 32

POOL: immutable(address)

@external
def __init__(_pool: address):
    """
    @notice Initialize Aave V3 Pool address
    @dev Sets value of state variable pool
    @param _pool Address of the Aave V3 pool (formerly lending pool)
    """
    POOL = _pool

@external
def executeOperation(
    _asset: address,
    _amount: uint256,
    _premium: uint256,
    _initiator: address, 
    _params: Bytes[MAX_PARAMS_LEN]
) -> bool: 
    """
    @notice Executes logic with borrowed asset and set approval
    @dev This method is called by the Aave Pool
    @param _asset Addresses of asset borrowed
    @param _amount Amount of asset borrowed (raw)
    @param _premium Premium owed for asset borrowed (raw)
    @param _initiator Address of the initiator of the flash loan
    @param _params Arbitrary params passed by the initiator
    @return True if execution success
    """
    # conduct logic
    # ...

    # approve transfer back to pool
    amount_owed: uint256 = _amount + _premium
    ERC20(_asset).approve(POOL, amount_owed)      

    return True

@external
def flash_call(
    _asset: address,
    _amount: uint256,
    _params: Bytes[MAX_PARAMS_LEN],
    _referral_code: Bytes[2]
):
    """
    @notice Make flash loan call to pool
    @dev Uses raw_call, since uint16 is not supported in vyper
    @param _asset Address of asset to borrow
    @param _amount Amount of asset to borrow (raw)
    @param _params Arbitrary params to pass to the receiver
    @param _referral_code Optional Aave referral code
    """
    receiver_address: address = self
    
    raw_call(
        POOL,
        _abi_encode(
            receiver_address,
            _asset,
            _amount,
            _params,
            _referral_code,
            method_id=method_id("flashLoanSimple(address,address,uint256,bytes,uint16)")
        )
    )
