const fs = require("fs");
const md5 = require("md5");
const { spawn } = require("child_process");

const FILENAME = "./npc_behavior.rbxlx";

let md5Prev = null;

const runLune = () => {
    console.log("Building behavior trees model...");
    const lune = spawn("lune", ["sync_behavior_trees.lua"])
    lune.on("close", (code) => {
        if (code == 0) {
            console.log("Behavior trees built successfully");
        } else {
            console.log(`Lune closed unsuccessfully with code ${code}`);
        }
    });
};

fs.watch(FILENAME, (event, filename) => {
    if (filename) {
        const md5Cur = md5(fs.readFileSync(FILENAME));
        if (md5Cur == md5Prev) {
            return;
        }
        md5Prev = md5Cur;
        console.log(`${filename} updated.`)
        runLune();
    }

});

console.log(`Watching for changes on ${FILENAME}`);
runLune();