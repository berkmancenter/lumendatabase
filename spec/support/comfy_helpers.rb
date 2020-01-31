module ComfyHelpers
  # We must destroy the cms thoroughly to avoid cross-pollution in the test
  # suite. Comfy::Cms::Site.first.destroy doesn't seem to do it -- layouts and
  # pages get swept up in dependent: destroy, but fragments linger, and block
  # reimportation due to failure of a uniqueness constraint.
  def destroy_cms
    Comfy::Cms::Site.destroy_all
    Comfy::Cms::Fragment.destroy_all
  end
end
