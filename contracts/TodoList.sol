// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract TodoList {
    struct User {
        string username;
        address userAccount;
        uint256 JoinTime;
    }

    struct Tasks {
        bytes32 id;
        bytes32 nextTask;
        address user;
        string title;
        string description;
        uint256 timestamp;
        uint256 updated;
    }

    struct Notes {
        bytes32 id;
        bytes32 nextNote;
        address user;
        string title;
        string keywords;
        string description;
        uint256 timestamp;
        uint256 updated;
    }

    uint256 public usersCount;
    bytes32 taskHead;
    bytes32 NoteHead;

    mapping(address => uint256) public taskcount;
    mapping(address => uint256) public notescount;

    constructor() {
        usersCount = 0;
        taskHead = 0;
        NoteHead = 0;
    }

    mapping(address => User) Users;
    event NewUser(string username, address account, uint256 Joiningtime);

    mapping(bytes32 => Tasks) userTasksMap;
    event NewTask(address user, bytes32 id, string title, uint256 timestamp);

    mapping(bytes32 => Notes) userNotesMap;
    event NewNote(address user, bytes32 id, string title, uint256 timestamp);

    function createUser(string memory username) public returns (User memory) {
        /**
         * @notice Retrieves all tasks related to the user calling this function.
         * @dev The task details are returned as an array of Tasks structs.
         * @return Returns an array of Task structs which contains information about each task including id, nextTask pointer, user address, title, description, timestamp and updated.
         */ Users[msg.sender] = User({
            username: username,
            userAccount: msg.sender,
            JoinTime: block.timestamp
        });
        emit NewUser(username, msg.sender, block.timestamp);
        usersCount++;
        return Users[msg.sender];
    }

    function getUser() public view returns (User memory) {
        return Users[msg.sender];
    }

    function createTask(
        string memory title,
        string memory description
    ) public returns (Tasks memory) {
        bytes32 taskId = keccak256(
            abi.encodePacked(msg.sender, block.timestamp, title)
        );
        userTasksMap[taskId] = Tasks({
            id: taskId,
            nextTask: 0,
            user: msg.sender,
            title: title,
            description: description,
            timestamp: block.timestamp,
            updated: 0
        });

        if (taskHead == 0) {
            taskHead = taskId;
        } else {
            bytes32 q = taskHead;
            while (userTasksMap[q].nextTask != 0) {
                q = userTasksMap[q].nextTask;
            }
            userTasksMap[q].nextTask = taskId;
        }
        if (taskcount[msg.sender] == 0) {
            taskcount[msg.sender] = 1;
        } else {
            taskcount[msg.sender]++;
        }

        emit NewTask(msg.sender, taskId, title, block.timestamp);

        return userTasksMap[taskId];
    }

    function getAllTasks() public view returns (Tasks[] memory) {
        Tasks[] memory alltasks = new Tasks[](taskcount[msg.sender]);
        if (taskHead == 0) {
            return alltasks;
        } else {
            bytes32 q = taskHead;
            for (uint i = 0; q != 0; ) {
                if (userTasksMap[q].user == msg.sender) {
                    alltasks[i] = userTasksMap[q];
                    i++;
                }
                q = userTasksMap[q].nextTask;
            }
        }

        return alltasks;
    }

    function updateTask(
        uint256 taskNum,
        string memory title,
        string memory description
    ) public {
        require(
            taskcount[msg.sender] >= taskNum,
            "No such task Present! Please check your TaskNumber! "
        );
        bytes32 q = taskHead;
        uint256 count = 1;
        while (q != 0) {
            if (userTasksMap[q].user == msg.sender) {
                if (count == taskNum) {
                    userTasksMap[q].title = title;
                    userTasksMap[q].description = description;
                    userTasksMap[q].updated++;
                    return;
                }
                count++;
            }

            q = userTasksMap[q].nextTask;
        }
    }

    function deleteTask(uint256 taskNum) public {
        require(
            taskcount[msg.sender] >= taskNum,
            "No such task Present! Please check your TaskNumber! "
        );
        bytes32 q = taskHead;
        if (taskNum == 1 && userTasksMap[taskHead].user == msg.sender) {
            taskHead = userTasksMap[taskHead].nextTask;
            taskcount[msg.sender]--;
            return;
        }
        uint256 count = 1;
        while (q != 0) {
            if (userTasksMap[q].user == msg.sender) {
                if (count == taskNum - 1) {
                    bytes32 temp = userTasksMap[q].nextTask;
                    userTasksMap[q].nextTask = userTasksMap[temp].nextTask;
                    taskcount[msg.sender]--;
                    return;
                }
                count++;
            }

            q = userTasksMap[q].nextTask;
        }
    }

    /**
     * @notice This function allows a user to create a new note with given title, description and keywords.
     * @dev The details of the note are stored as part of the Notes struct in the contract's state. A unique id for each note is also generated based on the user address, current timestamp, title and keywords.
     * @param title - This is the title of the note which will be added to the blockchain.
     * @param description - This is the content of the note that will be added to the blockchain.
     * @param keywords - These are additional details about the note used for search functionality in the future if required.
     * @return Returns a Note struct which contains information about each note including id, nextNote pointer, user address, title, description, timestamp and updated.
     */

    function createNote(
        string memory title,
        string memory description,
        string memory keywords
    ) public returns (Notes memory) {
        bytes32 noteId = keccak256(
            abi.encodePacked(msg.sender, block.timestamp, title, keywords)
        );
        userNotesMap[noteId] = Notes({
            id: noteId,
            nextNote: 0,
            user: msg.sender,
            title: title,
            keywords: keywords,
            description: description,
            timestamp: block.timestamp,
            updated: 0
        });

        if (NoteHead == 0) {
            NoteHead = noteId;
        } else {
            bytes32 q = NoteHead;
            while (userNotesMap[q].nextNote != 0) {
                q = userNotesMap[q].nextNote;
            }
            userNotesMap[q].nextNote = noteId;
        }
        if (notescount[msg.sender] == 0) {
            notescount[msg.sender] = 1;
        } else {
            notescount[msg.sender]++;
        }

        emit NewNote(msg.sender, noteId, title, block.timestamp);

        return userNotesMap[noteId];
    }

    function getAllNotes() public view returns (Notes[] memory) {
        Notes[] memory allnotes = new Notes[](notescount[msg.sender]);
        if (NoteHead == 0) {
            return allnotes;
        } else {
            bytes32 q = NoteHead;
            for (uint i = 0; q != 0; ) {
                if (userNotesMap[q].user == msg.sender) {
                    allnotes[i] = userNotesMap[q];
                    i++;
                }
                q = userNotesMap[q].nextNote;
            }
        }

        return allnotes;
    }

    function updateNote(
        uint256 NoteNum,
        string memory title,
        string memory description,
        string memory keywords
    ) public {
        require(
            notescount[msg.sender] >= NoteNum,
            "No such Note Present! Please check your TaskNumber! "
        );
        bytes32 q = NoteHead;
        uint256 count = 1;
        while (q != 0) {
            if (userNotesMap[q].user == msg.sender) {
                if (count == NoteNum) {
                    userNotesMap[q].title = title;
                    userNotesMap[q].description = description;
                    userNotesMap[q].keywords = keywords;
                    userNotesMap[q].updated++;
                    return;
                }
                count++;
            }

            q = userNotesMap[q].nextNote;
        }
    }

    function deleteNote(uint256 noteNum) public {
        require(
            notescount[msg.sender] >= noteNum,
            "No such task Present! Please check your TaskNumber! "
        );
        bytes32 q = NoteHead;
        if (noteNum == 1 && userNotesMap[NoteHead].user == msg.sender) {
            NoteHead = userNotesMap[NoteHead].nextNote;
            notescount[msg.sender]--;
            return;
        }
        uint256 count = 1;
        while (q != 0) {
            if (userNotesMap[q].user == msg.sender) {
                if (count == noteNum - 1) {
                    bytes32 temp = userNotesMap[q].nextNote;
                    userNotesMap[q].nextNote = userNotesMap[temp].nextNote;
                    notescount[msg.sender]--;
                    return;
                }
                count++;
            }

            q = userNotesMap[q].nextNote;
        }
    }
}
