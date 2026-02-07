enum CustomMapType {
    RECTANGLE = "rectangle",
    CIRCLE = "circle",
    POLYGON = "polygon",
    POLYLINE = "polyline",
    MULTIPOLYGON = "multipolygon"
}

interface PresetMap{
    name: string;
    id: string;
    type: CustomMapType;
    coordinates: number[][];
    radius?: number;
}

interface User {
    id: string;
    username: string;
    hashedPassword: string;
    email: string;
    firstName?: string;
    lastName?: string;
    profilePictureUrl?: string;
    isAdmin: boolean;
}

interface TokenPayload {
    userId: string;
    username: string;
    isAdmin: boolean;
}

export { CustomMapType, PresetMap, User, TokenPayload };