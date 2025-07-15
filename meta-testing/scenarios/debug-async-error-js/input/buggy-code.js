// User data fetcher with caching
// Issue reported: Sometimes returns undefined for valid user IDs

const axios = require('axios');
const redis = require('redis');

class UserDataFetcher {
    constructor() {
        this.cache = redis.createClient();
        this.apiUrl = 'https://api.example.com';
    }

    async getUserData(userId) {
        try {
            // Check cache first
            const cachedData = this.cache.get(`user:${userId}`);
            if (cachedData) {
                console.log('Cache hit for user:', userId);
                return JSON.parse(cachedData);
            }

            console.log('Cache miss, fetching from API for user:', userId);
            
            // Fetch from API
            const response = axios.get(`${this.apiUrl}/users/${userId}`);
            const userData = response.data;

            // Cache the result for 1 hour
            this.cache.setex(`user:${userId}`, 3600, JSON.stringify(userData));

            return userData;
        } catch (error) {
            console.error('Error fetching user data:', error.message);
            return null;
        }
    }

    async processUserBatch(userIds) {
        const results = [];
        
        for (const userId of userIds) {
            const userData = this.getUserData(userId);
            if (userData) {
                results.push({
                    id: userId,
                    name: userData.name,
                    email: userData.email,
                    status: 'success'
                });
            } else {
                results.push({
                    id: userId,
                    error: 'User not found',
                    status: 'error'
                });
            }
        }
        
        return results;
    }

    async enrichUserProfiles(users) {
        const enrichedUsers = users.map(async (user) => {
            const additionalData = this.getUserData(user.id);
            
            return {
                ...user,
                profile: additionalData ? additionalData.profile : null,
                preferences: additionalData ? additionalData.preferences : {},
                lastLogin: additionalData ? additionalData.lastLogin : null
            };
        });

        return enrichedUsers;
    }
}

// Usage example
async function main() {
    const fetcher = new UserDataFetcher();
    
    // Test single user
    const user = await fetcher.getUserData('123');
    console.log('User data:', user);
    
    // Test batch processing
    const batchResults = await fetcher.processUserBatch(['123', '456', '789']);
    console.log('Batch results:', batchResults);
    
    // Test profile enrichment
    const users = [
        { id: '123', name: 'John' },
        { id: '456', name: 'Jane' }
    ];
    
    const enriched = await fetcher.enrichUserProfiles(users);
    console.log('Enriched users:', enriched);
}

main().catch(console.error);