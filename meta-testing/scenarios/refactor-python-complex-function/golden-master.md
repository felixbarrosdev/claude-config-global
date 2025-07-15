# Refactored User Management System

## Analysis of the Original Code

The `complex_user_operation` function in `user_manager.py` suffers from several code smells:

1. **Long Method**: 200+ lines in a single function
2. **Multiple Responsibilities**: Handles CRUD operations, validation, authentication, and database access
3. **Complex Conditional Logic**: Large switch-like structure for different operation types
4. **Code Duplication**: Repeated validation patterns and database operations
5. **Tight Coupling**: Direct database access mixed with business logic
6. **Poor Testability**: Difficult to test individual operations in isolation

## Refactored Solution

Here's the refactored version that addresses these issues:

### 1. Main UserManager Class (Refactored)

```python
#!/usr/bin/env python3
"""
Refactored User management system with improved separation of concerns
"""

import sqlite3
from typing import Dict, Optional
from .validators import UserValidator
from .services import UserService, AuthService
from .operations import UserOperationFactory
from .exceptions import UserManagerError


class UserManager:
    """Main user manager with delegated responsibilities"""
    
    def __init__(self, db_path: str = "users.db"):
        self.db_path = db_path
        self.validator = UserValidator()
        self.user_service = UserService(db_path)
        self.auth_service = AuthService(db_path)
        self.operation_factory = UserOperationFactory(
            self.user_service, 
            self.auth_service, 
            self.validator
        )
        self.init_db()
    
    def init_db(self):
        """Initialize the database with user table"""
        self.user_service.init_database()
    
    def execute_user_operation(self, user_data: Dict, operation_type: str, 
                             admin_user_id: Optional[int] = None) -> Dict:
        """
        Execute a user operation using the appropriate strategy
        
        Args:
            user_data: Dictionary containing user information
            operation_type: Type of operation to perform
            admin_user_id: ID of admin user performing the operation (if applicable)
            
        Returns:
            Dictionary with operation result
            
        Raises:
            UserManagerError: For invalid operations or data
        """
        try:
            operation = self.operation_factory.create_operation(operation_type)
            return operation.execute(user_data, admin_user_id)
            
        except UserManagerError:
            raise
        except Exception as e:
            return {
                "success": False,
                "message": "Unexpected error occurred",
                "data": None,
                "errors": [str(e)]
            }


# Example usage
if __name__ == "__main__":
    user_manager = UserManager()
    
    # Create a user
    new_user = {
        "username": "testuser",
        "email": "test@example.com",
        "password": "SecurePass123!",
        "profile": {"first_name": "Test", "last_name": "User"}
    }
    
    result = user_manager.execute_user_operation(new_user, "create")
    print("Create user result:", result)
```

### 2. User Validation Service

```python
# validators.py
"""
User data validation service
"""

import re
from typing import Dict, List


class UserValidator:
    """Handles all user data validation"""
    
    EMAIL_PATTERN = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    def validate_create_user_data(self, user_data: Dict) -> List[str]:
        """Validate data for user creation"""
        errors = []
        
        # Check required fields
        required_fields = ["username", "email", "password"]
        errors.extend(self._validate_required_fields(user_data, required_fields))
        
        if not errors:  # Only validate format if required fields exist
            errors.extend(self._validate_email_format(user_data.get("email")))
            errors.extend(self._validate_password_strength(user_data.get("password")))
        
        return errors
    
    def validate_update_user_data(self, user_data: Dict) -> List[str]:
        """Validate data for user update"""
        errors = []
        
        if "user_id" not in user_data:
            errors.append("User ID is required for update operation")
            return errors
        
        if "email" in user_data:
            errors.extend(self._validate_email_format(user_data["email"]))
        
        if "password" in user_data:
            errors.extend(self._validate_password_strength(user_data["password"]))
        
        return errors
    
    def validate_auth_data(self, user_data: Dict) -> List[str]:
        """Validate authentication data"""
        errors = []
        required_fields = ["username", "password"]
        errors.extend(self._validate_required_fields(user_data, required_fields))
        return errors
    
    def _validate_required_fields(self, user_data: Dict, required_fields: List[str]) -> List[str]:
        """Validate that required fields are present and not empty"""
        errors = []
        for field in required_fields:
            if field not in user_data or not user_data[field]:
                errors.append(f"Missing required field: {field}")
        return errors
    
    def _validate_email_format(self, email: str) -> List[str]:
        """Validate email format"""
        if not re.match(self.EMAIL_PATTERN, email):
            return ["Invalid email format"]
        return []
    
    def _validate_password_strength(self, password: str) -> List[str]:
        """Validate password strength"""
        errors = []
        
        if len(password) < 8:
            errors.append("Password must be at least 8 characters long")
        if not re.search(r'[A-Z]', password):
            errors.append("Password must contain at least one uppercase letter")
        if not re.search(r'[a-z]', password):
            errors.append("Password must contain at least one lowercase letter")
        if not re.search(r'\d', password):
            errors.append("Password must contain at least one number")
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            errors.append("Password must contain at least one special character")
        
        return errors
```

### 3. Database Services

```python
# services.py
"""
Database services for user management
"""

import sqlite3
import hashlib
import json
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple


class DatabaseService:
    """Base database service"""
    
    def __init__(self, db_path: str):
        self.db_path = db_path
    
    def get_connection(self) -> sqlite3.Connection:
        """Get database connection"""
        return sqlite3.connect(self.db_path)


class UserService(DatabaseService):
    """Service for user CRUD operations"""
    
    def init_database(self):
        """Initialize the database with user table"""
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT UNIQUE NOT NULL,
                    email TEXT UNIQUE NOT NULL,
                    password_hash TEXT NOT NULL,
                    is_active BOOLEAN DEFAULT TRUE,
                    is_admin BOOLEAN DEFAULT FALSE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    last_login TIMESTAMP,
                    failed_login_attempts INTEGER DEFAULT 0,
                    account_locked_until TIMESTAMP,
                    profile_data TEXT
                )
            """)
    
    def create_user(self, user_data: Dict) -> Tuple[bool, str, Optional[int]]:
        """Create a new user"""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                # Check if username or email already exists
                if self._user_exists(cursor, user_data["username"], user_data["email"]):
                    return False, "Username or email already exists", None
                
                # Hash password and create user
                password_hash = self._hash_password(user_data["password"])
                profile_data = json.dumps(user_data.get("profile", {}))
                
                cursor.execute("""
                    INSERT INTO users (username, email, password_hash, is_admin, profile_data)
                    VALUES (?, ?, ?, ?, ?)
                """, (
                    user_data["username"], 
                    user_data["email"], 
                    password_hash,
                    user_data.get("is_admin", False), 
                    profile_data
                ))
                
                return True, "User created successfully", cursor.lastrowid
                
        except sqlite3.Error as e:
            return False, f"Database error: {str(e)}", None
    
    def update_user(self, user_data: Dict, admin_user_id: Optional[int] = None) -> Tuple[bool, str]:
        """Update an existing user"""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                user_id = user_data["user_id"]
                
                # Check if user exists
                if not self._user_exists_by_id(cursor, user_id):
                    return False, "User not found"
                
                # Build dynamic update query
                update_fields, update_values = self._build_update_query(
                    user_data, cursor, admin_user_id
                )
                
                if not update_fields:
                    return True, "No fields to update"
                
                update_values.append(user_id)
                update_query = f"UPDATE users SET {', '.join(update_fields)} WHERE id = ?"
                cursor.execute(update_query, update_values)
                
                return True, "User updated successfully"
                
        except sqlite3.Error as e:
            return False, f"Database error: {str(e)}"
    
    def delete_user(self, user_id: int, admin_user_id: int) -> Tuple[bool, str]:
        """Delete a user (admin only)"""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                # Verify admin permissions
                if not self._is_admin_user(cursor, admin_user_id):
                    return False, "Only administrators can delete users"
                
                cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
                
                if cursor.rowcount > 0:
                    return True, "User deleted successfully"
                else:
                    return False, "User not found"
                    
        except sqlite3.Error as e:
            return False, f"Database error: {str(e)}"
    
    def _user_exists(self, cursor: sqlite3.Cursor, username: str, email: str) -> bool:
        """Check if user exists by username or email"""
        cursor.execute("SELECT id FROM users WHERE username = ? OR email = ?", (username, email))
        return cursor.fetchone() is not None
    
    def _user_exists_by_id(self, cursor: sqlite3.Cursor, user_id: int) -> bool:
        """Check if user exists by ID"""
        cursor.execute("SELECT id FROM users WHERE id = ?", (user_id,))
        return cursor.fetchone() is not None
    
    def _is_admin_user(self, cursor: sqlite3.Cursor, user_id: int) -> bool:
        """Check if user is admin"""
        cursor.execute("SELECT is_admin FROM users WHERE id = ?", (user_id,))
        result = cursor.fetchone()
        return result and result[0]
    
    def _hash_password(self, password: str) -> str:
        """Hash password using SHA-256"""
        return hashlib.sha256(password.encode()).hexdigest()
    
    def _build_update_query(self, user_data: Dict, cursor: sqlite3.Cursor, 
                           admin_user_id: Optional[int]) -> Tuple[List[str], List]:
        """Build dynamic update query"""
        update_fields = []
        update_values = []
        
        if "email" in user_data:
            # Check email uniqueness
            cursor.execute("SELECT id FROM users WHERE email = ? AND id != ?", 
                         (user_data["email"], user_data["user_id"]))
            if cursor.fetchone():
                raise ValueError("Email already exists")
            
            update_fields.append("email = ?")
            update_values.append(user_data["email"])
        
        if "password" in user_data:
            password_hash = self._hash_password(user_data["password"])
            update_fields.append("password_hash = ?")
            update_values.append(password_hash)
        
        if "is_admin" in user_data:
            if admin_user_id and not self._is_admin_user(cursor, admin_user_id):
                raise ValueError("Only administrators can modify admin status")
            
            update_fields.append("is_admin = ?")
            update_values.append(user_data["is_admin"])
        
        if "profile" in user_data:
            profile_data = json.dumps(user_data["profile"])
            update_fields.append("profile_data = ?")
            update_values.append(profile_data)
        
        return update_fields, update_values


class AuthService(DatabaseService):
    """Service for authentication operations"""
    
    MAX_FAILED_ATTEMPTS = 5
    LOCKOUT_DURATION_MINUTES = 30
    
    def authenticate_user(self, username: str, password: str) -> Tuple[bool, str, Optional[Dict]]:
        """Authenticate a user"""
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                # Get user data
                user_record = self._get_user_for_auth(cursor, username)
                if not user_record:
                    return False, "Invalid username or password", None
                
                user_id, username, email, stored_hash, is_active, failed_attempts, locked_until = user_record
                
                # Check account status
                if not is_active:
                    return False, "Account is deactivated", None
                
                # Check if account is locked
                if self._is_account_locked(cursor, user_id, locked_until):
                    return False, "Account is temporarily locked", None
                
                # Verify password
                if self._verify_password(password, stored_hash):
                    self._handle_successful_login(cursor, user_id)
                    return True, "Authentication successful", {
                        "user_id": user_id,
                        "username": username,
                        "email": email
                    }
                else:
                    error_msg = self._handle_failed_login(cursor, user_id, failed_attempts)
                    return False, error_msg, None
                    
        except sqlite3.Error as e:
            return False, f"Database error: {str(e)}", None
    
    def _get_user_for_auth(self, cursor: sqlite3.Cursor, username: str) -> Optional[Tuple]:
        """Get user data for authentication"""
        cursor.execute("""
            SELECT id, username, email, password_hash, is_active, failed_login_attempts, 
                   account_locked_until FROM users WHERE username = ?
        """, (username,))
        return cursor.fetchone()
    
    def _is_account_locked(self, cursor: sqlite3.Cursor, user_id: int, locked_until: str) -> bool:
        """Check if account is locked"""
        if not locked_until:
            return False
        
        locked_until_dt = datetime.fromisoformat(locked_until)
        if datetime.now() >= locked_until_dt:
            # Unlock account if lock period has expired
            cursor.execute(
                "UPDATE users SET account_locked_until = NULL, failed_login_attempts = 0 WHERE id = ?", 
                (user_id,)
            )
            return False
        
        return True
    
    def _verify_password(self, password: str, stored_hash: str) -> bool:
        """Verify password against stored hash"""
        password_hash = hashlib.sha256(password.encode()).hexdigest()
        return password_hash == stored_hash
    
    def _handle_successful_login(self, cursor: sqlite3.Cursor, user_id: int):
        """Handle successful login"""
        cursor.execute(
            "UPDATE users SET last_login = CURRENT_TIMESTAMP, failed_login_attempts = 0 WHERE id = ?", 
            (user_id,)
        )
    
    def _handle_failed_login(self, cursor: sqlite3.Cursor, user_id: int, failed_attempts: int) -> str:
        """Handle failed login attempt"""
        failed_attempts += 1
        
        if failed_attempts >= self.MAX_FAILED_ATTEMPTS:
            lock_until = datetime.now() + timedelta(minutes=self.LOCKOUT_DURATION_MINUTES)
            cursor.execute(
                "UPDATE users SET failed_login_attempts = ?, account_locked_until = ? WHERE id = ?",
                (failed_attempts, lock_until.isoformat(), user_id)
            )
            return f"Too many failed attempts. Account locked for {self.LOCKOUT_DURATION_MINUTES} minutes."
        else:
            cursor.execute(
                "UPDATE users SET failed_login_attempts = ? WHERE id = ?", 
                (failed_attempts, user_id)
            )
            return "Invalid username or password"
```

### 4. Operation Strategy Pattern

```python
# operations.py
"""
User operation strategies using Strategy pattern
"""

from abc import ABC, abstractmethod
from typing import Dict, Optional
from .validators import UserValidator
from .services import UserService, AuthService
from .exceptions import UserManagerError


class UserOperation(ABC):
    """Abstract base class for user operations"""
    
    @abstractmethod
    def execute(self, user_data: Dict, admin_user_id: Optional[int] = None) -> Dict:
        """Execute the user operation"""
        pass


class CreateUserOperation(UserOperation):
    """Strategy for creating users"""
    
    def __init__(self, user_service: UserService, validator: UserValidator):
        self.user_service = user_service
        self.validator = validator
    
    def execute(self, user_data: Dict, admin_user_id: Optional[int] = None) -> Dict:
        # Validate input
        errors = self.validator.validate_create_user_data(user_data)
        if errors:
            return {"success": False, "message": "", "data": None, "errors": errors}
        
        # Create user
        success, message, user_id = self.user_service.create_user(user_data)
        
        return {
            "success": success,
            "message": message,
            "data": {"user_id": user_id} if user_id else None,
            "errors": [] if success else [message]
        }


class UpdateUserOperation(UserOperation):
    """Strategy for updating users"""
    
    def __init__(self, user_service: UserService, validator: UserValidator):
        self.user_service = user_service
        self.validator = validator
    
    def execute(self, user_data: Dict, admin_user_id: Optional[int] = None) -> Dict:
        # Validate input
        errors = self.validator.validate_update_user_data(user_data)
        if errors:
            return {"success": False, "message": "", "data": None, "errors": errors}
        
        # Update user
        success, message = self.user_service.update_user(user_data, admin_user_id)
        
        return {
            "success": success,
            "message": message,
            "data": None,
            "errors": [] if success else [message]
        }


class DeleteUserOperation(UserOperation):
    """Strategy for deleting users"""
    
    def __init__(self, user_service: UserService):
        self.user_service = user_service
    
    def execute(self, user_data: Dict, admin_user_id: Optional[int] = None) -> Dict:
        if "user_id" not in user_data:
            return {
                "success": False,
                "message": "",
                "data": None,
                "errors": ["User ID is required for delete operation"]
            }
        
        if not admin_user_id:
            return {
                "success": False,
                "message": "",
                "data": None,
                "errors": ["Admin user ID is required for delete operation"]
            }
        
        # Delete user
        success, message = self.user_service.delete_user(user_data["user_id"], admin_user_id)
        
        return {
            "success": success,
            "message": message,
            "data": None,
            "errors": [] if success else [message]
        }


class AuthenticateUserOperation(UserOperation):
    """Strategy for authenticating users"""
    
    def __init__(self, auth_service: AuthService, validator: UserValidator):
        self.auth_service = auth_service
        self.validator = validator
    
    def execute(self, user_data: Dict, admin_user_id: Optional[int] = None) -> Dict:
        # Validate input
        errors = self.validator.validate_auth_data(user_data)
        if errors:
            return {"success": False, "message": "", "data": None, "errors": errors}
        
        # Authenticate user
        success, message, auth_data = self.auth_service.authenticate_user(
            user_data["username"], 
            user_data["password"]
        )
        
        return {
            "success": success,
            "message": message,
            "data": auth_data,
            "errors": [] if success else [message]
        }


class UserOperationFactory:
    """Factory for creating user operation strategies"""
    
    def __init__(self, user_service: UserService, auth_service: AuthService, validator: UserValidator):
        self.user_service = user_service
        self.auth_service = auth_service
        self.validator = validator
        
        self.operations = {
            "create": CreateUserOperation(user_service, validator),
            "update": UpdateUserOperation(user_service, validator),
            "delete": DeleteUserOperation(user_service),
            "authenticate": AuthenticateUserOperation(auth_service, validator),
        }
    
    def create_operation(self, operation_type: str) -> UserOperation:
        """Create and return the appropriate operation strategy"""
        if operation_type not in self.operations:
            raise UserManagerError(f"Invalid operation type: {operation_type}")
        
        return self.operations[operation_type]
```

### 5. Custom Exceptions

```python
# exceptions.py
"""
Custom exceptions for user management
"""


class UserManagerError(Exception):
    """Base exception for user manager errors"""
    pass


class ValidationError(UserManagerError):
    """Exception for validation errors"""
    pass


class AuthenticationError(UserManagerError):
    """Exception for authentication errors"""
    pass


class DatabaseError(UserManagerError):
    """Exception for database-related errors"""
    pass
```

## Benefits of the Refactored Version

### 1. **Single Responsibility Principle**
- Each class has one clear responsibility
- `UserValidator` handles only validation
- `UserService` manages CRUD operations
- `AuthService` handles authentication
- Each operation strategy handles one specific operation

### 2. **Improved Testability**
- Individual components can be tested in isolation
- Mock objects can easily replace dependencies
- Validation logic is separated and easily testable

### 3. **Better Code Organization**
- Related functionality is grouped together
- Clear separation between validation, business logic, and data access
- Easy to locate and modify specific functionality

### 4. **Extensibility**
- New operations can be added by implementing the `UserOperation` interface
- New validation rules can be added to the validator
- Services can be extended without affecting other components

### 5. **Reduced Duplication**
- Common validation logic is centralized
- Database connection handling is abstracted
- Error handling patterns are consistent

### 6. **Improved Error Handling**
- Custom exceptions provide better error context
- Consistent error response format
- Better separation of different error types

### 7. **Configuration and Dependency Injection**
- Dependencies are injected through constructors
- Easy to configure different implementations
- Better control over object lifecycle

## Testing Strategy

The refactored code enables comprehensive testing:

```python
# Example test structure
class TestUserValidator:
    def test_validate_create_user_data_missing_fields(self):
        # Test validation with missing required fields
        pass
    
    def test_validate_password_strength(self):
        # Test password validation rules
        pass

class TestUserService:
    def test_create_user_success(self):
        # Test successful user creation
        pass
    
    def test_create_user_duplicate_email(self):
        # Test duplicate email handling
        pass

class TestAuthService:
    def test_authenticate_valid_user(self):
        # Test successful authentication
        pass
    
    def test_authenticate_account_lockout(self):
        # Test account lockout functionality
        pass

class TestUserOperations:
    def test_create_operation_integration(self):
        # Integration test for create operation
        pass
```

This refactored solution transforms a single, complex function into a well-organized, maintainable, and testable system that follows SOLID principles and clean code practices.