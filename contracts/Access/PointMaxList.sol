pragma solidity 0.6.12;

/**
 * @dev GP Make a whitelist but instead of adding and removing, set an uint amount for a address
 * @dev mapping(address => uint256) public points;
 * @dev This amount can be added or removed by an operator
 * @dev Can update an array of points
 */

import "../OpenZeppelin/math/SafeMath.sol";
import "./MISOAccessControls.sol";
import "../interfaces/IPointList.sol";


contract PointMaxList is IPointList, MISOAccessControls {
    using SafeMath for uint;

    /// @notice Maping an address to a number fo points.
    mapping(address => uint256) public pointsMap;

    /// @notice Event emitted when points are updated.
    event PointsUpdated(address indexed account, uint256 oldPoints, uint256 newPoints);


    constructor() public {
    }

    /**
     * @notice Initializes point list with admin address.
     * @param _admin Admins address.
     */
    function initPointList(address _admin) public override {
        initAccessControls(_admin);
    }

    /**
     * @notice Validates and returns the amount of points an account has.
     * @param _account Account address.
     * @return uint256 Amount of points.
     */
    function points(address _account) public view returns (uint256) {
        if(pointsMap[_account] > 0) {
            return pointsMap[_account];
        }

        return pointsMap[address(0)];
    }

    /**
     * @notice Checks if account address is in the list (has any points).
     * @param _account Account address.
     * @return bool True or False.
     */
    function isInList(address _account) public view override returns (bool) {
        if(pointsMap[_account] > 0) {
            return true;
        }

        if(pointsMap[address(0)] > 0) {
            return true;
        }

        return false;
    }

    /**
     * @notice Checks if account has more or equal points as the number given.
     * @param _account Account address.
     * @param _amount Desired amount of points.
     * @return bool True or False.
     */
    function hasPoints(address _account, uint256 _amount) public view override returns (bool) {
        if(pointsMap[_account] >= _amount) {
            return true;
        }

        if(pointsMap[address(0)] >= _amount) {
            return true;
        }

        return false;
    }

    /**
     * @notice Sets points to accounts in one batch.
     * @param _accounts An array of accounts.
     * @param _amounts An array of corresponding amounts.
     */
    function setPoints(address[] memory _accounts, uint256[] memory _amounts) external override {
        require(hasAdminRole(msg.sender) || hasOperatorRole(msg.sender), "PointList.setPoints: Sender must be operator");
        require(_accounts.length != 0);
        require(_accounts.length == _amounts.length);
        for (uint i = 0; i < _accounts.length; i++) {
            address account = _accounts[i];
            uint256 amount = _amounts[i];
            uint256 previousPoints = pointsMap[account];

            if (amount != previousPoints) {
                pointsMap[account] = amount;
                emit PointsUpdated(account, previousPoints, amount);
            }
        }
    }
}
