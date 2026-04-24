-- ============================================================
-- Pet Project Tracker DB
-- ============================================================


-- ============================================================
-- ДОМЕНИ
-- ============================================================

CREATE DOMAIN domain_email AS VARCHAR(255)
    CHECK (VALUE ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');

CREATE DOMAIN domain_color AS VARCHAR(7)
    CHECK (VALUE ~ '^#[0-9A-Fa-f]{6}$');

CREATE DOMAIN domain_progress AS SMALLINT
    CHECK (VALUE BETWEEN 0 AND 100);

CREATE DOMAIN domain_priority AS SMALLINT
    CHECK (VALUE BETWEEN 0 AND 3);

CREATE DOMAIN domain_short_text AS VARCHAR(100)
    CHECK (LENGTH(TRIM(VALUE)) > 0);

CREATE DOMAIN domain_title AS VARCHAR(255)
    CHECK (LENGTH(TRIM(VALUE)) > 0);

CREATE TYPE project_status AS ENUM ('idea', 'active', 'pause', 'done');
CREATE TYPE task_status     AS ENUM ('todo', 'in_progress', 'done');
CREATE TYPE event_type      AS ENUM ('deadline', 'reminder', 'milestone');


-- ============================================================
-- ТАБЛИЦІ
-- ============================================================

CREATE TABLE users (
    id            SERIAL            PRIMARY KEY,
    email         domain_email      NOT NULL,
    password_hash TEXT              NOT NULL,
    name          domain_short_text,
    nickname      VARCHAR(50),
    created_at    TIMESTAMP         NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP         NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_users_email    UNIQUE (email),
    CONSTRAINT uq_users_nickname UNIQUE (nickname),
    CONSTRAINT chk_users_nickname CHECK (nickname IS NULL OR LENGTH(TRIM(nickname)) > 0)
);

CREATE TABLE projects (
    id          SERIAL           PRIMARY KEY,
    user_id     INT              NOT NULL,
    title       domain_title     NOT NULL,
    description TEXT,
    status      project_status   NOT NULL DEFAULT 'idea',
    progress    domain_progress  NOT NULL DEFAULT 0,
    deadline    DATE,
    created_at  TIMESTAMP        NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP        NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_projects_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT uq_projects_user_title UNIQUE (user_id, title),

    CONSTRAINT chk_projects_deadline
        CHECK (deadline IS NULL OR deadline >= CURRENT_DATE)
);

CREATE TABLE tags (
    id    SERIAL            PRIMARY KEY,
    name  domain_short_text NOT NULL,
    color domain_color      NOT NULL DEFAULT '#888888',

    CONSTRAINT uq_tags_name UNIQUE (name)
);


CREATE TABLE project_tags (
    project_id INT NOT NULL,
    tag_id     INT NOT NULL,

    CONSTRAINT pk_project_tags PRIMARY KEY (project_id, tag_id),

    CONSTRAINT fk_pt_project
        FOREIGN KEY (project_id) REFERENCES projects(id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_pt_tag
        FOREIGN KEY (tag_id) REFERENCES tags(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE tasks (
    id         SERIAL          PRIMARY KEY,
    project_id INT             NOT NULL,
    title      domain_title    NOT NULL,
    status     task_status     NOT NULL DEFAULT 'todo',
    priority   domain_priority NOT NULL DEFAULT 0,
    due_date   DATE,
    created_at TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_tasks_project
        FOREIGN KEY (project_id) REFERENCES projects(id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT uq_tasks_project_title UNIQUE (project_id, title),

    CONSTRAINT chk_tasks_due_date
        CHECK (due_date IS NULL OR due_date >= CURRENT_DATE)
);

CREATE TABLE calendar_events (
    id         SERIAL       PRIMARY KEY,
    user_id    INT          NOT NULL,
    project_id INT          NOT NULL,
    title      domain_title NOT NULL,
    event_date TIMESTAMP    NOT NULL,
    event_type event_type   NOT NULL DEFAULT 'deadline',
    created_at TIMESTAMP    NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_ce_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_ce_project
        FOREIGN KEY (project_id) REFERENCES projects(id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT uq_ce_project_date_type UNIQUE (project_id, event_date, event_type)
);


-- ============================================================
-- ТРИГЕР: автоматично оновлює updated_at при зміні рядка
-- ============================================================

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TRIGGER trg_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE TRIGGER trg_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- ============================================================
-- ІНДЕКСИ
-- ============================================================

CREATE UNIQUE INDEX idx_users_email       ON users(email);

CREATE INDEX idx_projects_user_id         ON projects(user_id);
CREATE INDEX idx_projects_status          ON projects(status);
CREATE INDEX idx_projects_deadline        ON projects(deadline);

CREATE INDEX idx_tasks_project_id         ON tasks(project_id);
CREATE INDEX idx_tasks_status             ON tasks(status);
CREATE INDEX idx_tasks_priority           ON tasks(priority);

CREATE INDEX idx_pt_project_id            ON project_tags(project_id);
CREATE INDEX idx_pt_tag_id                ON project_tags(tag_id);

CREATE INDEX idx_ce_user_id               ON calendar_events(user_id);
CREATE INDEX idx_ce_project_id            ON calendar_events(project_id);
CREATE INDEX idx_ce_event_date            ON calendar_events(event_date);
CREATE INDEX idx_ce_event_type            ON calendar_events(event_type);
