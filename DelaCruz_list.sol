// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ToDoList {
    struct Task {
        uint id;
        string description;
        bool isCompleted;
    }

    mapping(uint => Task) private tasks;
    uint private nextTaskId;

    event TaskCreated(uint id, string description);
    event TaskUpdated(uint id, string description, bool isCompleted);
    event TaskDeleted(uint id);

    // Add a new task (or chores)
    function addTask(string memory _description) public {
        require(bytes(_description).length > 0, "Task description cannot be empty");
        tasks[nextTaskId] = Task(nextTaskId, _description, false);
        emit TaskCreated(nextTaskId, _description);
        nextTaskId++;
    }

    // Update a task's status (true or false)
    function updateTask(uint _taskId, string memory _newDescription, bool _isCompleted) public {
        require(_taskId < nextTaskId, "Task does not exist");
        Task storage task = tasks[_taskId];
        require(!task.isCompleted, "Task is already completed");
        task.description = _newDescription;
        task.isCompleted = _isCompleted;
        emit TaskUpdated(_taskId, _newDescription, _isCompleted);
    }

    // remove a task
    function deleteTask(uint _taskId) public {
        require(_taskId < nextTaskId, "Task does not exist");
        Task storage task = tasks[_taskId];
        if (task.isCompleted == false) {
            revert("Cannot delete an incomplete task");
        }
        delete tasks[_taskId];
        emit TaskDeleted(_taskId);
    }

    // Get task information
    function getTask(uint _taskId) public view returns (uint, string memory, bool) {
        require(_taskId < nextTaskId, "Task does not exist");
        Task memory task = tasks[_taskId];
        return (task.id, task.description, task.isCompleted);
    }

    // Safety check: Ensure nextTaskId is never less than current tasks
    function safetyCheck() public view {
        assert(nextTaskId >= 0);
    }
}
