#!/usr/bin/env python3
"""
User management system with complex function that needs refactoring
"""

import hashlib
import json
import re
import sqlite3
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple


class UserManager:
    def __init__(self, db_path: str = "users.db"):
        self.db_path = db_path
        self.init_db()
    
    def init_db(self):
        """Initialize the database with user table"""
        conn = sqlite3.connect(self.db_path)
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
        conn.commit()
        conn.close()
    
    def complex_user_operation(self, user_data: Dict, operation_type: str, admin_user_id: Optional[int] = None) -> Dict:
        """
        This is a complex function that handles multiple user operations
        and needs refactoring due to its length and multiple responsibilities.
        """
        result = {"success": False, "message": "", "data": None, "errors": []}
        
        try:
            # Input validation
            if not user_data or not isinstance(user_data, dict):
                result["errors"].append("Invalid user data provided")
                return result
            
            if operation_type not in ["create", "update", "delete", "authenticate", "reset_password", "lock_account", "unlock_account"]:
                result["errors"].append("Invalid operation type")
                return result
            
            # Database connection
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Operation: CREATE USER
            if operation_type == "create":
                # Validate required fields
                required_fields = ["username", "email", "password"]
                for field in required_fields:
                    if field not in user_data or not user_data[field]:
                        result["errors"].append(f"Missing required field: {field}")
                
                if result["errors"]:
                    return result
                
                # Validate email format
                email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                if not re.match(email_pattern, user_data["email"]):
                    result["errors"].append("Invalid email format")
                    return result
                
                # Validate password strength
                password = user_data["password"]
                if len(password) < 8:
                    result["errors"].append("Password must be at least 8 characters long")
                if not re.search(r'[A-Z]', password):
                    result["errors"].append("Password must contain at least one uppercase letter")
                if not re.search(r'[a-z]', password):
                    result["errors"].append("Password must contain at least one lowercase letter")
                if not re.search(r'\d', password):
                    result["errors"].append("Password must contain at least one number")
                if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
                    result["errors"].append("Password must contain at least one special character")
                
                if result["errors"]:
                    return result
                
                # Check if username or email already exists
                cursor.execute("SELECT id FROM users WHERE username = ? OR email = ?", (user_data["username"], user_data["email"]))
                if cursor.fetchone():
                    result["errors"].append("Username or email already exists")
                    return result
                
                # Hash password
                password_hash = hashlib.sha256(password.encode()).hexdigest()
                
                # Create user
                profile_data = json.dumps(user_data.get("profile", {}))
                cursor.execute("""
                    INSERT INTO users (username, email, password_hash, is_admin, profile_data)
                    VALUES (?, ?, ?, ?, ?)
                """, (user_data["username"], user_data["email"], password_hash, 
                      user_data.get("is_admin", False), profile_data))
                
                new_user_id = cursor.lastrowid
                result["success"] = True
                result["message"] = "User created successfully"
                result["data"] = {"user_id": new_user_id}
            
            # Operation: UPDATE USER
            elif operation_type == "update":
                if "user_id" not in user_data:
                    result["errors"].append("User ID is required for update operation")
                    return result
                
                user_id = user_data["user_id"]
                
                # Check if user exists
                cursor.execute("SELECT id, username, email FROM users WHERE id = ?", (user_id,))
                existing_user = cursor.fetchone()
                if not existing_user:
                    result["errors"].append("User not found")
                    return result
                
                # Build update query dynamically
                update_fields = []
                update_values = []
                
                if "email" in user_data:
                    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                    if not re.match(email_pattern, user_data["email"]):
                        result["errors"].append("Invalid email format")
                        return result
                    
                    # Check if email is already taken by another user
                    cursor.execute("SELECT id FROM users WHERE email = ? AND id != ?", (user_data["email"], user_id))
                    if cursor.fetchone():
                        result["errors"].append("Email already exists")
                        return result
                    
                    update_fields.append("email = ?")
                    update_values.append(user_data["email"])
                
                if "password" in user_data:
                    password = user_data["password"]
                    if len(password) < 8:
                        result["errors"].append("Password must be at least 8 characters long")
                        return result
                    
                    password_hash = hashlib.sha256(password.encode()).hexdigest()
                    update_fields.append("password_hash = ?")
                    update_values.append(password_hash)
                
                if "is_admin" in user_data:
                    # Check if admin user is performing this operation
                    if admin_user_id:
                        cursor.execute("SELECT is_admin FROM users WHERE id = ?", (admin_user_id,))
                        admin_check = cursor.fetchone()
                        if not admin_check or not admin_check[0]:
                            result["errors"].append("Only administrators can modify admin status")
                            return result
                    
                    update_fields.append("is_admin = ?")
                    update_values.append(user_data["is_admin"])
                
                if "profile" in user_data:
                    profile_data = json.dumps(user_data["profile"])
                    update_fields.append("profile_data = ?")
                    update_values.append(profile_data)
                
                if update_fields:
                    update_values.append(user_id)
                    update_query = f"UPDATE users SET {', '.join(update_fields)} WHERE id = ?"
                    cursor.execute(update_query, update_values)
                    
                    result["success"] = True
                    result["message"] = "User updated successfully"
                else:
                    result["message"] = "No fields to update"
            
            # Operation: AUTHENTICATE USER
            elif operation_type == "authenticate":
                if "username" not in user_data or "password" not in user_data:
                    result["errors"].append("Username and password are required for authentication")
                    return result
                
                username = user_data["username"]
                password = user_data["password"]
                
                # Get user data
                cursor.execute("""
                    SELECT id, username, email, password_hash, is_active, failed_login_attempts, 
                           account_locked_until FROM users WHERE username = ?
                """, (username,))
                user_record = cursor.fetchone()
                
                if not user_record:
                    result["errors"].append("Invalid username or password")
                    return result
                
                user_id, username, email, stored_hash, is_active, failed_attempts, locked_until = user_record
                
                # Check if account is active
                if not is_active:
                    result["errors"].append("Account is deactivated")
                    return result
                
                # Check if account is locked
                if locked_until:
                    locked_until_dt = datetime.fromisoformat(locked_until)
                    if datetime.now() < locked_until_dt:
                        result["errors"].append("Account is temporarily locked")
                        return result
                    else:
                        # Unlock account if lock period has expired
                        cursor.execute("UPDATE users SET account_locked_until = NULL, failed_login_attempts = 0 WHERE id = ?", (user_id,))
                
                # Verify password
                password_hash = hashlib.sha256(password.encode()).hexdigest()
                if password_hash == stored_hash:
                    # Successful login
                    cursor.execute("UPDATE users SET last_login = CURRENT_TIMESTAMP, failed_login_attempts = 0 WHERE id = ?", (user_id,))
                    result["success"] = True
                    result["message"] = "Authentication successful"
                    result["data"] = {"user_id": user_id, "username": username, "email": email}
                else:
                    # Failed login
                    failed_attempts += 1
                    if failed_attempts >= 5:
                        # Lock account for 30 minutes
                        lock_until = datetime.now() + timedelta(minutes=30)
                        cursor.execute("UPDATE users SET failed_login_attempts = ?, account_locked_until = ? WHERE id = ?", 
                                     (failed_attempts, lock_until.isoformat(), user_id))
                        result["errors"].append("Too many failed attempts. Account locked for 30 minutes.")
                    else:
                        cursor.execute("UPDATE users SET failed_login_attempts = ? WHERE id = ?", (failed_attempts, user_id))
                        result["errors"].append("Invalid username or password")
                    return result
            
            # Operation: DELETE USER
            elif operation_type == "delete":
                if "user_id" not in user_data:
                    result["errors"].append("User ID is required for delete operation")
                    return result
                
                # Check if admin user is performing this operation
                if admin_user_id:
                    cursor.execute("SELECT is_admin FROM users WHERE id = ?", (admin_user_id,))
                    admin_check = cursor.fetchone()
                    if not admin_check or not admin_check[0]:
                        result["errors"].append("Only administrators can delete users")
                        return result
                
                user_id = user_data["user_id"]
                cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
                
                if cursor.rowcount > 0:
                    result["success"] = True
                    result["message"] = "User deleted successfully"
                else:
                    result["errors"].append("User not found")
            
            # Commit transaction
            conn.commit()
            
        except sqlite3.Error as e:
            result["errors"].append(f"Database error: {str(e)}")
        except Exception as e:
            result["errors"].append(f"Unexpected error: {str(e)}")
        finally:
            if 'conn' in locals():
                conn.close()
        
        return result


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
    
    result = user_manager.complex_user_operation(new_user, "create")
    print("Create user result:", result)