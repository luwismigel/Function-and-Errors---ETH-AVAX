// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DailyRewardProgram {
    address public programAdmin;
    uint public constant REWARD_POINTS_PER_TASK = 20;
    uint public constant POINTS_REDEMPTION_THRESHOLD = 120;
    uint public constant TASK_COMPLETION_TIME_LIMIT = 86400; // 24 hours in seconds

    struct RewardTask {
        string title;
        string details;
        uint createdAt;
        bool isCompleted;
    }

    mapping(address => RewardTask[]) private userTasks;
    mapping(address => uint) private userPoints;

    modifier onlyProgramAdmin() {
        require(msg.sender == programAdmin, "Only the program admin can use this function");
        _;
    }

    constructor() {
        programAdmin = msg.sender;
    }

    // Input a new task for the sender
    function registerTask(string memory _title, string memory _details) public {
        require(bytes(_title).length > 0, "Task title required!");
        require(bytes(_details).length > 0, "Task details  required!");

        userTasks[msg.sender].push(RewardTask(_title, _details, block.timestamp, false));
    }

    // Complete a task and earn points if completed within the time limit
    function finishTask(uint _taskIndex) public {
        require(_taskIndex < userTasks[msg.sender].length, "Invalid task");

        RewardTask storage task = userTasks[msg.sender][_taskIndex];
        require(!task.isCompleted, "Task  completed");

        // Check if the task is being completed within the time limit
        if (block.timestamp <= task.createdAt + TASK_COMPLETION_TIME_LIMIT) {
            task.isCompleted = true;
            userPoints[msg.sender] += REWARD_POINTS_PER_TASK; // Award points for completion
        } else {
            revert("completion time exceeded");
        }
    }

    // Redeem points once the user has reached the threshold
    function redeemPoints(uint _points) public {
        require(userPoints[msg.sender] >= _points, "Insufficient points for redeem");

        uint prevPoints = userPoints[msg.sender];
        userPoints[msg.sender] -= _points;

        // Ensure points were deducted correctly
        assert(userPoints[msg.sender] == prevPoints - _points);
    }

    // Get user's total points balance
    function getPoints() public view returns (uint) {
        return userPoints[msg.sender];
    }

    // Get user's tasks
    function getTasks() public view returns (RewardTask[] memory) {
        return userTasks[msg.sender];
    }
}
