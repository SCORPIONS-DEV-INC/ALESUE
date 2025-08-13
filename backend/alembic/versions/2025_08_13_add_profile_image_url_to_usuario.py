"""
add profile_image_url to usuario

Revision ID: add_profile_image_url_to_usuario
Revises: 2aec506e3ce7
Create Date: 2025-08-13
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'add_profile_image_url_to_usuario'
down_revision = '2aec506e3ce7'
branch_labels = None
depends_on = None

def upgrade():
    op.add_column('usuarios', sa.Column('profile_image_url', sa.String(), nullable=True))

def downgrade():
    op.drop_column('usuarios', 'profile_image_url')
