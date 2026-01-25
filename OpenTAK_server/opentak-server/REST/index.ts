import express, { Request, Response } from "express";
import * as dotenv from "dotenv";
import { addUser, getUserByUsername, getAllPresetMaps, addPresetMap, promoteUserToAdmin, startupChecks } from "./lib/db";
import { verifyPassword } from "./lib/passwords";
import { signToken, validateOnEndpointToken } from "./lib/tokens";
import { CustomMapType } from "./types";

dotenv.config();

const app = express();
const port = 3000;

let MQTT_BROKER_URL = process.env.MQTT_BROKER_URL || "mqtt://localhost:1883";

// If secret code is not set, default to empty string which means everyone can access
let SECRET_CODE = process.env.SECRET_CODE || "";
let SECRET = process.env.SECRET || "defaultsecret";

app.use(express.json());

let takServerVersion = "1.0.0";

app.get("/health", (req: Request, res: Response) => {
  res.send("OK");
});

app.get("/version", (req: Request, res: Response) => {
  res.json({ version: takServerVersion });
});

app.get("/mqtt-broker", (req: Request, res: Response) => {
  res.json({ mqttBrokerUrl: MQTT_BROKER_URL });
});

app.post("/register", async (req: Request, res: Response) => {
    const secretCode = req.headers["x-secret-code"] as string | undefined;
    if (SECRET_CODE !== "" && secretCode !== SECRET_CODE) {
        return res.status(403).json({ error: "Forbidden" });
    }

    let username = req.body.username;
    let password = req.body.password;
    let email = req.body.email;

    if (!username || !password || !email) {
        return res.status(400).json({ error: "Missing required fields" });
    }
    
    await addUser(username, password, email, false)
        .then((user) => {
            res.status(201).json({ message: "User registered successfully", userId: user.id });
        })
        .catch((error) => {
            console.error("Error registering user:", error);
            res.status(500).json({ error: "Internal server error" });
        });
});

app.post("/login", async (req: Request, res: Response) => {
    let username = req.body.username;
    let password = req.body.password;

    if (!username || !password) {
        return res.status(400).json({ error: "Missing required fields" });
    }

    const user = await getUserByUsername(username);
    if (!user) {
        return res.status(401).json({ error: "Invalid username or password" });
    }

    const passwordValid = await verifyPassword(password, user.hashedPassword);
    if (!passwordValid) {
        return res.status(401).json({ error: "Invalid username or password" });
    }

    const tokenPayload = {
        userId: user.id,
        username: user.username,
        isAdmin: user.isAdmin
    };

    const token = await signToken(tokenPayload, SECRET, { expiresIn: '30d' });

    // Return the token to the client via JSON response
    res.json({ token });
});

app.get("/login", async (req: Request, res: Response) => {
    const authHeader = req.headers["token"] as string | undefined;
    if (!authHeader) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    const token = authHeader;

    const valid = await validateOnEndpointToken(token, SECRET);
    if (!valid) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    res.json({ message: "Token is valid" });
});

app.get("/list-maps", (req: Request, res: Response) => {

    let authHeader = req.headers["token"] as string | undefined;
    if (!authHeader) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    let token = authHeader;

    validateOnEndpointToken(token, SECRET).then((valid) => {
        if (!valid) {
            return res.status(401).json({ error: "Unauthorized" });
        }

        getAllPresetMaps().then((maps) => {
            res.json({ maps });
        }).catch((error) => {
            console.error("Error fetching preset maps:", error);
            res.status(500).json({ error: "Internal server error" });
        });
    });
});

app.post("/add-map", (req: Request, res: Response) => {
    let authHeader = req.headers["token"] as string | undefined;
    if (!authHeader) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    let token = authHeader;

    validateOnEndpointToken(token, SECRET).then((valid) => {
        if (!valid) {
            return res.status(401).json({ error: "Unauthorized" });
        }

        let mapName = req.body.name;
        let mapType = req.body.type as CustomMapType;
        let coordinates = req.body.coordinates;
        let radius = req.body.radius;

        if (!mapName || !mapType || !coordinates) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        if (!Object.values(CustomMapType).includes(mapType)) {
            return res.status(400).json({ error: "Invalid map type" });
        }

        if (mapType === CustomMapType.CIRCLE && (radius === undefined || radius === null)) {
            return res.status(400).json({ error: "Missing radius for circle map type" });
        }

        if (mapType === CustomMapType.RECTANGLE && coordinates.length !== 2) {
            return res.status(400).json({ error: "Rectangle map type requires exactly 2 coordinate points" });
        }

        addPresetMap(mapName, mapType, coordinates, radius).catch((error) => {
            console.error("Error adding preset map:", error);
            return res.status(500).json({ error: "Internal server error" });
        });

        res.json({ message: "Map added successfully" });
    });
});

app.post("/promote-user", (req: Request, res: Response) => {
    let authHeader = req.headers["token"] as string | undefined;
    if (!authHeader) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    let token = authHeader;

    validateOnEndpointToken(token, SECRET).then(async (valid) => {
        if (!valid) {
            return res.status(401).json({ error: "Unauthorized" });
        }

        const payload = await validateOnEndpointToken(token, SECRET);
        if (!payload || !payload.isAdmin) {
            return res.status(403).json({ error: "Forbidden" });
        }

        let usernameToPromote = req.body.username;
        if (!usernameToPromote) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        await promoteUserToAdmin(usernameToPromote).catch((error) => {
            console.error("Error promoting user to admin:", error);
            return res.status(500).json({ error: "Internal server error" });
        });

        res.json({ message: "User promoted to admin successfully" });
    });
});

app.listen(port, async () => {
    await startupChecks();
    console.log(`REST server is running at http://localhost:${port}`);
});