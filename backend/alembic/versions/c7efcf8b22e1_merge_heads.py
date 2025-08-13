"""merge heads

Revision ID: c7efcf8b22e1
Revises: add_profile_image_url_to_usuario, edu_platform_001
Create Date: 2025-08-13 10:32:14.019037

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c7efcf8b22e1'
down_revision: Union[str, Sequence[str], None] = ('add_profile_image_url_to_usuario', 'edu_platform_001')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
