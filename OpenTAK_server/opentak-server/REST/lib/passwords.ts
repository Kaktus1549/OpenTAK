import argon2 from "argon2";

export async function hashPassword(password: string): Promise<string> {
    /* 
    Hash a plain text password
    @param password - The plain text password to hash
    @returns A promise that resolves to the hashed password
    */

    const hashedPassword = await argon2.hash(password);
    return hashedPassword;
}

export async function verifyPassword(hashedPassword: string, plainPassword: string): Promise<boolean> {
    /* 
    Verify a plain text password against a hashed password
    @param hashedPassword - The hashed password
    @param plainPassword - The plain text password to verify
    @returns A promise that resolves to true if the password matches, otherwise false
    */

    return await argon2.verify(hashedPassword, plainPassword);
}