document.addEventListener('turbolinks:load', function () {
  if (!$('.select-category')[0]) return false; //カテゴリのフォームが無いなら以降実行しない。

  function buildCategoryForm(categories) { // 子孫カテゴリのフォームを組み立てる
    console.log(categories);
    let options = "";
    categories.forEach(function (category) { // カテゴリを一つずつ渡してoptionタグを一つずつ組み立てていく。
      options += `
                  <option value="${category.id}">${category.name}</option>
                 `;
    });

    let name = `name="item[category_id]"`;
    var required_true = `required="required"`;
    let blank = "---";

    if ($("#item_search")[0]) {
      name = "name=q[category_id_in][]";
      required_true = '';
      blank = "すべて";
    }

    const html = `
                  <select ${required_true} ${name} class="select-category search-form-added" name="item[category_id]">
                    <option value="">${blank}</option>
                    ${options}
                  </select>
                 `;
    return html;
  }

  function buildCollectionForm(array, attribute) {
    var options = setCollectionOption(array, attribute);
    var html = `
    <div class= "search-checkboxes search-form-added">
      ${options}
    </select>
    </div>
    `
    return html;
  };

  function setCollectionOption(options, attribute) {
    var option_list = ``
    $.each(options, function (i, option) {
      option_list += `
      <input type="checkbox" value= "${option.id}" name="q[${attribute}_in][]" id="q_${attribute}_in_${option.id}">
      <label for="q_${attribute}_in_${option.id}">${option.name}</label>
      `
    })
    return option_list;
  };

  $(document).on("change", ".select-category", function () { //カテゴリが選択された時
    const category_id = $(this).val();
    // var changed_form = $(this);

    $.ajax({
      url: "/api/categories",
      type: "GET",
      data: {category_id: category_id},
      dataType: 'json',
    })
    .done(function (categories) {
      if (categories.length == 0) return false;
      // changed_form.nextAll(".select-category").remove();
      // const html = buildCategoryForm(categories);
      // $(".select-category:last").after(html);

      let depth = $("select.select-category").index(this);
        // 詳細検索ページかつ変更されたのが子カテゴリの場合、孫カテゴリのフォームをチェックボックス式で作成する。
        if ($("#item_search")[0] && depth == 1) {
          var html = `
                    <div class= "select-category search-form-added">
                      ${buildCollectionForm(categories, "category_id")}
                    </div>
                    `
        } else {
          var html = buildCategoryForm(categories) // カテゴリのフォームを組み立ててる。
        }
        //主な変更点　↑ここまで
        $(this).nextAll('.select-category').remove(); // 後続（変更されたのが親カテゴリなら子孫全て、子カテゴリなら孫カテゴリ、孫カテゴリなら無し）を消去しておく。
        $("select.select-category:last").after(html); // カテゴリのフォームたちの一番最後にappendする。
    }.bind(this));
  });
});