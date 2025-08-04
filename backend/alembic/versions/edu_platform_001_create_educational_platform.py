"""create educational platform schema

Revision ID: edu_platform_001
Revises: 2aec506e3ce7
Create Date: 2025-08-04 12:10:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'edu_platform_001'
down_revision: Union[str, Sequence[str], None] = '2aec506e3ce7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Crear tabla usuarios con todos los campos necesarios
    op.create_table('usuarios',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('username', sa.String(), nullable=False),
        sa.Column('email', sa.String(), nullable=False),
        sa.Column('password_hash', sa.String(), nullable=False),
        sa.Column('rol', sa.Enum('estudiante', 'profesor', 'admin', name='rolenum'), nullable=False),
        sa.Column('nombre', sa.String(), nullable=False),
        sa.Column('apellido', sa.String(), nullable=False),
        sa.Column('dni', sa.String(), nullable=False),
        sa.Column('edad', sa.Integer(), nullable=True),
        sa.Column('grado', sa.String(), nullable=True),
        sa.Column('seccion', sa.String(), nullable=True),
        sa.Column('sexo', sa.String(), nullable=True),
        sa.Column('puntos_matematicas', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('puntos_comunicacion', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('puntos_personal_social', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('puntos_ciencia_tecnologia', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('puntos_ingles', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('puntos_totales', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('activo', sa.String(), nullable=False, server_default='true'),
        sa.Column('tenant_id', sa.String(), nullable=False, server_default='default'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()')),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('username'),
        sa.UniqueConstraint('email'),
        sa.UniqueConstraint('dni')
    )
    op.create_index(op.f('ix_usuarios_id'), 'usuarios', ['id'], unique=False)
    op.create_index(op.f('ix_usuarios_email'), 'usuarios', ['email'], unique=False)
    op.create_index(op.f('ix_usuarios_username'), 'usuarios', ['username'], unique=False)

    # Crear tabla retos
    op.create_table('retos',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('titulo', sa.String(), nullable=False),
        sa.Column('descripcion', sa.String(), nullable=False),
        sa.Column('puntos', sa.Integer(), nullable=False, server_default='10'),
        sa.Column('nivel', sa.Enum('facil', 'medio', 'dificil', name='nivelenum'), nullable=False),
        sa.Column('materia', sa.Enum('matematicas', 'comunicacion', 'personal_social', 'ciencia_tecnologia', 'ingles', name='materiaenum'), nullable=False),
        sa.Column('profesor_id', sa.Integer(), nullable=False),
        sa.Column('activo', sa.String(), nullable=False, server_default='true'),
        sa.Column('tenant_id', sa.String(), nullable=False, server_default='default'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime(timezone=True), onupdate=sa.text('now()')),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_retos_id'), 'retos', ['id'], unique=False)

    # Crear tabla progreso_retos
    op.create_table('progreso_retos',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('estudiante_id', sa.Integer(), nullable=False),
        sa.Column('reto_id', sa.Integer(), nullable=False),
        sa.Column('completado', sa.String(), nullable=False, server_default='false'),
        sa.Column('puntos_obtenidos', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('fecha_completado', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime(timezone=True), onupdate=sa.text('now()')),
        sa.ForeignKeyConstraint(['estudiante_id'], ['usuarios.id'], ),
        sa.ForeignKeyConstraint(['reto_id'], ['retos.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_progreso_retos_id'), 'progreso_retos', ['id'], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f('ix_progreso_retos_id'), table_name='progreso_retos')
    op.drop_table('progreso_retos')
    op.drop_index(op.f('ix_retos_id'), table_name='retos')
    op.drop_table('retos')
    op.drop_index(op.f('ix_usuarios_username'), table_name='usuarios')
    op.drop_index(op.f('ix_usuarios_email'), table_name='usuarios')
    op.drop_index(op.f('ix_usuarios_id'), table_name='usuarios')
    op.drop_table('usuarios')
    
    # Eliminar los enums
    op.execute('DROP TYPE IF EXISTS rolenum')
    op.execute('DROP TYPE IF EXISTS nivelenum')
    op.execute('DROP TYPE IF EXISTS materiaenum')
