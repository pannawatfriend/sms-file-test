
CREATE TABLE users (
    id VARCHAR(32),
    password_hash VARCHAR(72) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    deleted_at DATETIME(3),
    PRIMARY KEY (id)
);

CREATE TABLE devices (
    id CHAR(21),
    name VARCHAR(128),
    auth_token CHAR(21) NOT NULL,
    push_token VARCHAR(256),
    user_id VARCHAR(32) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    deleted_at DATETIME(3),
    PRIMARY KEY (id),
    UNIQUE INDEX idx_devices_auth_token (auth_token),
    CONSTRAINT fk_users_devices FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE messages (
    id BIGINT UNSIGNED AUTO_INCREMENT,
    device_id CHAR(21) NOT NULL,
    ext_id VARCHAR(36) NOT NULL,
    message TEXT NOT NULL,
    state ENUM('Pending', 'Processed', 'Sent', 'Delivered', 'Failed') NOT NULL DEFAULT 'Pending',
    valid_until DATETIME(3),
    sim_number TINYINT(1) UNSIGNED,
    with_delivery_report TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
    is_hashed TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
    is_encrypted TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
    priority TINYINT NOT NULL DEFAULT 0,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    deleted_at DATETIME(3),
    PRIMARY KEY (id),
    UNIQUE INDEX unq_messages_id_device (ext_id, device_id),
    INDEX idx_messages_device_state (device_id, state),
    INDEX idx_messages_is_hashed USING HASH (is_hashed),
    CONSTRAINT fk_messages_device FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);

CREATE TABLE message_recipients (
    id SERIAL NOT NULL PRIMARY KEY,
    message_id BIGINT UNSIGNED,
    phone_number VARCHAR(128) NOT NULL,
    state ENUM('Pending', 'Processed', 'Sent', 'Delivered', 'Failed') NOT NULL DEFAULT 'Pending',
    error VARCHAR(256),
    UNIQUE INDEX unq_message_recipients_message_id_phone_number (message_id, phone_number),
    CONSTRAINT fk_messages_recipients FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE
);

CREATE TABLE message_states (
    id BIGINT UNSIGNED AUTO_INCREMENT,
    message_id BIGINT UNSIGNED NOT NULL,
    state ENUM('Pending', 'Sent', 'Processed', 'Delivered', 'Failed') NOT NULL,
    updated_at DATETIME(3) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE INDEX unq_message_states_message_id_state (message_id, state),
    CONSTRAINT fk_messages_states FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE
);

CREATE TABLE webhooks (
    id BIGINT UNSIGNED AUTO_INCREMENT,
    ext_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(32) NOT NULL,
    url VARCHAR(256) NOT NULL,
    event VARCHAR(32) NOT NULL,
    device_id CHAR(21),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    deleted_at DATETIME(3),
    PRIMARY KEY (id),
    UNIQUE INDEX unq_webhooks_user_extid (user_id, ext_id),
    INDEX idx_webhooks_device (device_id),
    CONSTRAINT fk_webhooks_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_webhooks_device FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);

CREATE TABLE device_settings (
    user_id VARCHAR(32) NOT NULL,
    settings JSON NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (user_id),
    CONSTRAINT fk_device_settings_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

ALTER TABLE message_recipients ADD PRIMARY KEY (message_id, phone_number);

ALTER TABLE message_recipients MODIFY COLUMN phone_number VARCHAR(16) NOT NULL;

ALTER TABLE messages MODIFY COLUMN message TINYTEXT NOT NULL;

ALTER TABLE message_recipients MODIFY COLUMN state ENUM('Pending', 'Sent', 'Delivered', 'Failed') NOT NULL DEFAULT 'Pending';
ALTER TABLE messages MODIFY COLUMN state ENUM('Pending', 'Sent', 'Delivered', 'Failed') NOT NULL DEFAULT 'Pending';

ALTER TABLE message_recipients MODIFY COLUMN phone_number CHAR(11) NOT NULL;

CREATE UNIQUE INDEX unq_messages_device_id ON messages(device_id, ext_id);




