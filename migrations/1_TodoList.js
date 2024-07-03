var TodoList = artifacts.require("TodoList");

module.exports = function (deployer) {
	deployer
		.deploy(TodoList)
		.then(() => {
			console.log("TodoList contract deployed successfully!");
		})
		.catch((error) => {
			console.error("Deployment failed:", error);
		});
};
