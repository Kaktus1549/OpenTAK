import jwt from 'jsonwebtoken';
import { User } from '../types';
import { getUserById } from './db';

export async function signToken(payload: object, secret: string, options?: jwt.SignOptions): Promise<string> {
    return new Promise((resolve, reject) => {
        jwt.sign(payload, secret, options || {}, (err, token) => {
            if (err || !token) {
                return reject(err);
            }
            resolve(token);
        });
    });
}

export async function verifyToken<T>(token: string, secret: string): Promise<T> {
    return new Promise((resolve, reject) => {
        jwt.verify(token, secret, (err, decoded) => {
            if (err || !decoded) {
                return reject(err);
            }
            resolve(decoded as T);
        });
    });
}

export async function validateOnEndpointToken(token: string, secret: string): Promise<User | false> {
    try {
        let payload = await verifyToken<object>(token, secret);
        if (typeof payload !== 'object' || !('userId' in payload)) {
            return false;
        }

        let userId = (payload as any).userId;
        let user = await getUserById(userId);
        if (!user) {
            return false;
        }

        return {
            id: user.id,
            username: user.username,
            hashedPassword: user.hashedPassword,
            email: user.email,
            firstName: user.firstName || undefined,
            lastName: user.lastName || undefined,
            profilePictureUrl: user.profilePictureUrl || undefined,
            isAdmin: user.isAdmin
        }
    } catch {
        return false;
    }
}