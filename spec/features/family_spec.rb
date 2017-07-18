describe 'Family' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:province){create(:province,name:"Phnom Penh")}
  let!(:family){ create(:family, :emergency, name: 'EC Family', address: 'Phnom Penh', province_id: province.id) }
  let!(:other_family){ create(:family) }
  let!(:case){ create(:case, family: other_family) }
  let!(:client){ create(:client, :accepted) }
  let!(:other_client){ create(:client, state: '') }
  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit families_path
    end

    scenario 'name' do
      expect(page).to have_content(family.name)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_family_path(family))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{family_path(family)}'][data-method='delete']")
    end

    scenario 'show link' do
      expect(page).to have_link(nil, family_path(family))
    end

    scenario 'new link' do
      expect(page).to have_link('Add New Family', new_family_path)
    end
  end

  feature 'Create', js: true do
    before do
      visit new_family_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      fill_in 'Address', with: FFaker::Address.street_address
      fill_in 'Caregiver Information', with: FFaker::Lorem.paragraph
      find(".family_clients select option[value='#{client.id}']", visible: false).select_option
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Family has been successfully created')
      expect(page).to have_content(client.given_name)
      expect(page).not_to have_content(other_client.given_name)
    end

    xscenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end

    scenario 'Inactive Family' do
      fill_in 'Name', with: 'Inactive Family'
      find(".family_family_type select option[value='inactive']", visible: false).select_option
      find(".family_clients select option[value='#{client.id}']", visible: false).select_option
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Family has been successfully created')
      client.reload
      expect(client.status).to eq('Referred')
    end

    scenario 'Birth Family' do
      fill_in 'Name', with: 'Inactive Family'
      find(".family_family_type select option[value='birth_family']", visible: false).select_option
      find(".family_clients select option[value='#{client.id}']", visible: false).select_option
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Family has been successfully created')
      client.reload
      expect(client.status).to eq('Referred')
    end

    scenario 'Emergency Family' do
      fill_in 'Name', with: 'Emergency Family'
      find(".family_family_type select option[value='emergency']", visible: false).select_option
      find(".family_clients select option[value='#{client.id}']", visible: false).select_option
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Family has been successfully created')
      client.reload
      expect(client.status).to eq('Active EC')
    end

    scenario 'Foster Family' do
      fill_in 'Name', with: 'Foster Family'
      find(".family_family_type select option[value='foster']", visible: false).select_option
      find(".family_clients select option[value='#{client.id}']", visible: false).select_option
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Family has been successfully created')
      client.reload
      expect(client.status).to eq('Active FC')
    end

    scenario 'Kinship Family' do
      fill_in 'Name', with: 'Kinship Family'
      find(".family_family_type select option[value='kinship']", visible: false).select_option
      find(".family_clients select option[value='#{client.id}']", visible: false).select_option
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Family has been successfully created')
      client.reload
      expect(client.status).to eq('Active KC')
    end
  end

  feature 'Update', js: true do
    let!(:name) { FFaker::Name.name }
    let!(:pirunseng){ create(:client, :accepted, given_name: 'Pirun', family_name: 'Seng') }
    let!(:ec_family){ create(:family, :emergency, name: 'Emergency Family') }
    let!(:non_case_family){ create(:family, family_type: ['birth_family', 'inactive'].sample) }
    let!(:non_case){ create(:case, case_type: 'Referred', client: pirunseng, family: non_case_family) }
    let!(:ec_case){ create(:case, :emergency, client: pirunseng, family: ec_family) }

    feature 'valid' do
      before do
        visit edit_family_path(ec_family)
      end
      scenario 'name' do
        fill_in 'Name', with: name
        click_button 'Save'
        sleep 1
        expect(page).to have_content('Family has been successfully updated')
        expect(page).to have_content(name)
      end
    end

    feature 'remove clients from' do
      scenario 'case family is invalid' do
        visit edit_family_path(ec_family)
        unselect('Pirun Seng', from: 'Clients', visible: false)
        click_button 'Save'
        sleep 1
        expect(page).to have_content("You're not allowed to detach clients from the family through this form!")
      end

      scenario 'birth or inactive family is valid' do
        visit edit_family_path(non_case_family)
        unselect('Pirun Seng', from: 'Clients', visible: false)
        click_button 'Save'
        sleep 1
        expect(page).to have_content('Family has been successfully updated')
      end
    end
  end

  feature 'Delete', js: true do
    before do
      visit families_path
    end
    scenario 'success' do
      find("a[href='#{family_path(family)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content('Family has been successfully deleted')
    end
    scenario 'unsuccess' do
      expect(page).to have_css("a[href='#{family_path(other_family)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end

  feature 'Show' do
    before do
      visit family_path(family)
    end
    scenario 'success' do
      expect(page).to have_content(family.name)
    end
    scenario 'link to edit' do
      expect(page).to have_link(nil, href: edit_family_path(family, locale: I18n.locale))
    end
    scenario 'link to delete' do
      expect(page).to have_css("a[href='#{family_path(family, locale: I18n.locale)}'][data-method='delete']")
    end
    scenario 'disable delete' do
      visit family_path(other_family)
      expect(page).to have_css("a[href='#{family_path(other_family, locale: I18n.locale)}'][data-method='delete'][class='btn btn-outline btn-danger btn-md disabled']")
    end
  end

  feature 'Filter' do
    before do
      visit families_path
      find(".btn-filter").click
    end
    scenario 'filter by family type' do
      select('Emergency', from: 'family_grid_family_type')
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family)
    end

    scenario 'filter by family like name' do
      fill_in('family_grid_name',with: 'Family')
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family)
    end

    scenario 'filter by family id' do
      fill_in('family_grid_id',with: family.id)
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family)
    end

    scenario 'filter by family address' do
      fill_in('family_grid_address',with: 'Phnom Penh')
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family)
    end

    scenario 'filter by family province' do
      select('Phnom Penh', from: 'family_grid_province_id')
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family)
    end

    scenario 'filter by family dependable income' do
      select('No', from: 'family_grid_dependable_income')
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family)
    end

  end
end
