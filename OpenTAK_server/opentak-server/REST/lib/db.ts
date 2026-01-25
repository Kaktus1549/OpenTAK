import { prisma } from './prisma'
import { hashPassword } from './passwords';

export async function startupChecks() {
    // Check if in database is at least one administrator user
    const adminCount = await prisma.user.count({
        where: {
            isAdmin: true
        }
    });

    if (adminCount === 0) {
        // Get master user from environment variables
        const masterUser = process.env.MASTER_USER;
        const masterPassword = process.env.MASTER_PASSWORD;


        if (!masterUser || !masterPassword) {
            console.error("No administrator user found in database and MASTER_USER or MASTER_PASSWORD environment variables are not set.");
            process.exit(1);
        }
        let hashedPassword = await hashPassword(masterPassword);

        // Create the master admin user
        await prisma.user.create({
            data: {
                username: masterUser,
                hashedPassword: hashedPassword,
                email: `${masterUser}@localhost`,
                isAdmin: true
            }
        });

        console.log(`Master administrator user '${masterUser}' created.`);
    }
}

export async function addUser(username: string, password: string, email: string, isAdmin: boolean) {
    let hashedPassword = await hashPassword(password);

    const newUser = await prisma.user.create({
        data: {
            username: username,
            hashedPassword: hashedPassword,
            email: email,
            isAdmin: isAdmin
        }
    });

    return newUser;
}

export async function getUserByUsername(username: string) {
    const user = await prisma.user.findUnique({
        where: {
            username: username
        }
    });

    return user;
}

export async function getUserById(userId: string) {
    const user = await prisma.user.findUnique({
        where: {
            id: userId
        }
    });

    return user;
}

export async function getAllUsers() {
    const users = await prisma.user.findMany();
    return users;
}

export async function deleteUserById(userId: string) {
    const deletedUser = await prisma.user.delete({
        where: {
            id: userId
        }
    });

    return deletedUser;
}

export async function updateUserProfilePicture(userId: string, profilePictureUrl: string) {
    const updatedUser = await prisma.user.update({
        where: {
            id: userId
        },
        data: {
            profilePictureUrl: profilePictureUrl
        }
    });

    return updatedUser;
}

export async function getHashedPasswordByUsername(username: string) {
    const user = await prisma.user.findUnique({
        where: {
            username: username
        },
        select: {
            hashedPassword: true
        }
    });

    return user?.hashedPassword;
}

export async function getAllPresetMaps() {
    const maps = await prisma.presetMap.findMany();
    return maps;
}

export async function addPresetMap(name: string, type: string, coordinates: number[][], radius?: number) {
    const map = await prisma.presetMap.create({
        data: {
            name: name,
            type: type,
            coordinates: JSON.stringify(coordinates),
            radius: radius
        }
    });

    return map;
}

export async function deletePresetMapById(mapId: string) {
    const deletedMap = await prisma.presetMap.delete({
        where: {
            id: parseInt(mapId)
        }
    });

    return deletedMap;
}

export async function getPresetMapById(mapId: string) {
    const map = await prisma.presetMap.findUnique({
        where: {
            id: parseInt(mapId)
        }
    });

    return map;
}

export async function promoteUserToAdmin(userId: string) {
    const updatedUser = await prisma.user.update({
        where: {
            id: userId
        },
        data: {
            isAdmin: true
        }
    });

    return updatedUser;
}