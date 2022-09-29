@testset "AST" begin
    text = CommonMark.text
    root = text("root")

    CommonMark.insert_before(root, text("insert_before"))
    CommonMark.insert_after(root, text("insert_after"))
    @test root.prv.literal == "insert_before"
    @test root.nxt.literal == "insert_after"

    CommonMark.append_child(root, text("append_child"))
    @test root.first_child.literal == "append_child"
    @test root.last_child.literal == "append_child"

    CommonMark.prepend_child(root, text("prepend_child"))
    @test root.first_child.literal == "prepend_child"
    @test root.last_child.literal == "append_child"

    CommonMark.unlink(root.last_child)
    @test root.last_child.literal == "prepend_child"

    root = text("root")
    CommonMark.prepend_child(root, text("prepend_child"))
    @test root.first_child.literal == "prepend_child"
    @test root.last_child.literal == "prepend_child"
end
