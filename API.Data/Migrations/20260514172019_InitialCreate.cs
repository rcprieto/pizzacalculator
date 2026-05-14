using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace API.Data.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "tbc_ingrediente",
                columns: table => new
                {
                    ing_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    ing_nome = table.Column<string>(type: "longtext", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    ing_marca = table.Column<string>(type: "longtext", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    ing_preco = table.Column<decimal>(type: "decimal(10,4)", precision: 10, scale: 4, nullable: false),
                    ing_status = table.Column<bool>(type: "tinyint(1)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbc_ingrediente", x => x.ing_id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "tbc_receita",
                columns: table => new
                {
                    rec_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    rec_nome = table.Column<string>(type: "longtext", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    rec_modo_preparo = table.Column<string>(type: "longtext", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    rec_status = table.Column<bool>(type: "tinyint(1)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbc_receita", x => x.rec_id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "tbc_receita_item",
                columns: table => new
                {
                    rec_item_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    rec_id = table.Column<int>(type: "int", nullable: false),
                    ing_id = table.Column<int>(type: "int", nullable: false),
                    rec_item_peso_g = table.Column<decimal>(type: "decimal(10,3)", precision: 10, scale: 3, nullable: false),
                    percentual = table.Column<decimal>(type: "decimal(10,4)", precision: 10, scale: 4, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tbc_receita_item", x => x.rec_item_id);
                    table.ForeignKey(
                        name: "FK_tbc_receita_item_tbc_ingrediente_ing_id",
                        column: x => x.ing_id,
                        principalTable: "tbc_ingrediente",
                        principalColumn: "ing_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_tbc_receita_item_tbc_receita_rec_id",
                        column: x => x.rec_id,
                        principalTable: "tbc_receita",
                        principalColumn: "rec_id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "IX_tbc_receita_item_ing_id",
                table: "tbc_receita_item",
                column: "ing_id");

            migrationBuilder.CreateIndex(
                name: "IX_tbc_receita_item_rec_id",
                table: "tbc_receita_item",
                column: "rec_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "tbc_receita_item");

            migrationBuilder.DropTable(
                name: "tbc_ingrediente");

            migrationBuilder.DropTable(
                name: "tbc_receita");
        }
    }
}
